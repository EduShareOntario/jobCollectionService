subscriptionMgr = new SubsManager { expireIn: 3 }

Template.transcriptList.onCreated () ->
  self = this
  @autorun () ->
    userId = Meteor.userId() # force evaluation if user changes
    subscription = subscriptionMgr.subscribe "transcripts", Meteor.user(), {
      onReady: () ->
        console.log "transcriptList autorun subscribed to 'transcripts' publication. when userId is #{userId}"
        # See https://meteor.hackpad.com/Blaze-Proposals-for-v0.2-hsd54WPJmDV  and https://meteorhacks.com/kadira-blaze-hooks
        Deps.afterFlush () ->
          console.log "transcriptList autorun afterFlush following subscribe ready, DOM should exist. when userId is #{userId}"
          $('[data-role="page"]').trigger("create")
    }
    if (subscription.ready())
      console.log "subscription ready!"
      $('[data-role="page"]').trigger("create")
    console.log "subscribed to 'transcripts' publication when userId is #{userId}"

  self.transcripts = () ->
    console.log "transcripts() called from template onCreated event handler."
    return transcripts()

transcripts = () ->
  console.log "transcripts() called"
  cursor = Transcript.documents.find {reviewCompletedOn: undefined}, {sort: {created: 1}}
  cursor.observe {
    added: (item) ->
      Deps.afterFlush () ->
        $('[data-role="collapsible-set"]').enhanceWithin()
  }
  return cursor

Template.transcriptList.helpers {
  transcripts: () ->
    console.log "transcripts() helper called"
    return Template.instance().transcripts()
}

Template.transcriptList.events
  'click .view-transcript': (e, t) ->
    Meteor.call "startReview", this._id

Template.transcriptList.onRendered () ->
  template = this
#
# The following code realizes the recipe documented at http://stackoverflow.com/questions/25486954/meteor-rendered-callback-and-applying-jquery-plugins.
# In our case we need to initialize jQuery Mobile elements!
#
# Based on article explanation:
# As a quick recap, this is what is happening with this code under the hood :
#   - Template.transcriptList.rendered is called but the #each block has not yet rendered the transcriptSummary items.
#   - Our reactive computation is setup and we listen to updates from the 'transcripts' collection (just like the #each block is doing in its own distinct computation).
#   - Some time later, the 'transcripts' collection is updated and both the #each block computation as well as our custom computation are invalidated - because they depend
#     on the SAME cursor - and thus will rerun.
#     Now the tricky part is that we can't tell which computation is going to rerun first, it could be one or the other, in an nondeterministic way.
#     This is why we need to run the plugin initialization in a Deps.afterFlush callback.
#   - The #each block logic is executed and items get inserted in the DOM.
#   - The flush cycle (rerunning every invalidated computations) is done and our Deps.afterFlush callback is thus executed.
#
#   This pattern allows us to reinitialize our jQuery plugins (carousels, masonry-like stuff, etc...) whenever new items are being added to the model and subsequently rendered in the DOM by Blaze.
#
  template.autorun () ->
    # reference a reactive dependency such that this 'autorun' computation will get called whenever it changes!
    t = transcripts()
    # afterFlush so the DOM is ready!
    Deps.afterFlush () ->
      $('[data-role="collapsible-set"]').enhanceWithin()


Template.transcriptSummary.helpers
  academicRecords: () ->
    # Reactively populate
    recs = this.pescCollegeTranscript.CollegeTranscript.Student.AcademicRecord
    recs = [recs] unless recs is Array
    return recs

  pathForTranscriptReview: () ->
    path = FlowRouter.path "transcriptReviewDetail", {transcriptId: this._id}
    return path
