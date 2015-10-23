Tracker.autorun () ->
  # Update the subscription when the userId changes.
  userId = Meteor.userId()
  Meteor.subscribe 'transcripts', { onReady: () -> console.log("transcripts-pending-review collection is ready!")}
  #todo:  keep the X-Auth-Token cookie up-to-date
  # $.cookie 'X-Auth-Token', Accounts._storedLoginToken()

Template.body.rendered =
  () ->
    # refresh jQM controls
    $('[data-role="page"]').trigger('create');

Template.transcript.rendered =
  () ->
    # Jquery Mobile requires refresh of Javascript manipulated elements!
    $('[data-role="collapsible-set"]').collapsibleset("refresh")
#    $('[data-role="button"]').button('refresh')
    $(this.view.firstNode().parentElement).enhanceWithin()


Template.transcript.helpers
  academicRecords: () ->
    # Reactively populate
    recs = this.pescCollegeTranscript.CollegeTranscript.Student.AcademicRecord
    recs = [recs] unless recs is Array
    return recs

Template.transcript.events
    'click .review-complete': (e, t) ->
      console.log "User selected 'Review complete' for transcript: #{this._id}"
      transcript = Template.currentData()
      Meteor.call "completeReview", transcript._id

#Write your package code here!
#Template.body.helpers({
#  transcripts: () ->
#    return Transcript.documents.find( {reviewComplete: false}, {sort: {createdAt: -1}})
