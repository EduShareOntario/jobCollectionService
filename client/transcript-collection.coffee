Tracker.autorun () ->
  #todo:  keep the X-Auth-Token cookie up-to-date
  # $.cookie 'X-Auth-Token', Accounts._storedLoginToken()

Template.onRendered () ->
  node = this.firstNode
  if (node)
    template = this.view.name
    $(node).addClass('is-template').attr('data-template', template)

Template.body.rendered =
  () ->
    console.log "Template.body.rendered."
    # refresh jQuery Mobile controls
    $('[data-role="page"]').trigger('create');

Template.transcriptsMainLayout.rendered =
  () ->
    console.log "Template.transcriptsMainLayout.rendered"
    # refresh jQuery Mobile controls
    $('[data-role="page"]').trigger('create');

Template.transcriptList.onCreated () ->
  self = this
  @autorun () ->
    subscription = self.subscribe "transcripts", {
      onReady: () ->
        console.log "transcriptList autorun subscribed to 'transcripts' publication."
        # See https://meteor.hackpad.com/Blaze-Proposals-for-v0.2-hsd54WPJmDV  and https://meteorhacks.com/kadira-blaze-hooks
        Deps.afterFlush () ->
          console.log "afterFlush following subscribe ready, DOM should exist "
          $('[data-role="page"]').trigger("create")
    }
    if (subscription.ready())
      console.log "subscription ready!"
    else
      console.log "subscription not ready!"

  self.transcripts = () ->
    return transcripts()

transcripts = () ->
  console.log "transcripts() function called"
  cursor = Transcript.documents.find {reviewCompletedOn: undefined}, {sort: {created: -1}}
  console.log "transcripts() function called,  cursor: " + JSON.stringify(cursor)
  return cursor

Template.transcriptList.helpers {
  transcripts: () ->
    return Template.instance().transcripts()

  initializeTemplateElements: () ->
# refresh jQuery Mobile controls
#    $('[data-role="page"]').trigger('create');
    $(this.view.firstNode().parentElement).enhanceWithin()
    $('[data-role="collapsible-set"]').collapsibleset("refresh")
}

Template.transcriptList.events
  'click .view-transcript': (e, t) ->
    console.log "User selected 'View Transcript' for transcript: #{this._id}"
    Meteor.call "startReview", this._id

Template.transcriptList.rendered = () ->
  console.log "transcriptList rendered"
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
  computation = Deps.autorun (comp) ->
      # reference a reactive dependency such that this 'autorun' computation will get called whenever it changes!
      t = transcripts()
      # afterFlush so the DOM is ready!
      Deps.afterFlush () ->
        console.log "afterFlush, DOM should exist "
        console.log "computation :" + JSON.stringify(comp)
#        $('[data-role="collapsible-set"]').collapsibleset("refresh")

  console.log JSON.stringify(computation)

Template.transcriptSummary.helpers
  academicRecords: () ->
# Reactively populate
    recs = this.pescCollegeTranscript.CollegeTranscript.Student.AcademicRecord
    recs = [recs] unless recs is Array
    return recs

  pathForTranscriptReview: () ->
    path = FlowRouter.path "transcriptReviewDetail", {transcriptId: this._id}
    return path

Template.transcriptDetail.onCreated () ->
  self = this
  @autorun () ->
    transcriptId = FlowRouter.getParam('transcriptId')
    subscription = self.subscribe "transcript", transcriptId, {
      onReady: () ->
        console.log "transcriptList autorun subscribed to 'transcript' #{transcriptId} publications"
        # See https://meteor.hackpad.com/Blaze-Proposals-for-v0.2-hsd54WPJmDV  and https://meteorhacks.com/kadira-blaze-hooks
        Deps.afterFlush () ->
          console.log "afterFlush following subscribe ready, DOM should exist "
          $('[data-role="page"]').trigger("create")
    }
    if (subscription.ready())
      console.log "subscription ready!"
    else
      console.log "subscription not ready!"

Template.transcriptDetail.rendered = () ->
  # Jquery Mobile requires refresh of Javascript manipulated elements!
  $(this.view.firstNode().parentElement).enhanceWithin()

Template.transcriptDetail.helpers
  transcript: () ->
    transcriptId = FlowRouter.getParam('transcriptId')
    return Transcript.documents.findOne(transcriptId) || {}

Template.transcriptDetail.events =
  'click .review-complete': (e) ->
    console.log "User completed review of transcript: #{this._id}"
    Meteor.call "completeReview", this._id

  'click .cancel-review': (e) ->
    console.log "User cancelled review of transcript: #{this._id}"
    Meteor.call "cancelReview", this._id


BlazeLayout.setRoot '#page'
transcriptReviewRouter = FlowRouter.group {prefix: "/transcriptReview"}

transcriptReviewRouter.route '/', {
  name: 'transcriptReviewList'
  action: () ->
    console.log "Rendering transcript review list"
    BlazeLayout.render "transcriptsMainLayout", {content: "transcriptList"}
}

transcriptReviewRouter.route '/:transcriptId', {
  name: 'transcriptReviewDetail',
  action: (params) ->
    console.log "Reviewing transcript:", params.transcriptId
    BlazeLayout.render "transcriptsMainLayout", {content: "transcriptDetail"}
}
