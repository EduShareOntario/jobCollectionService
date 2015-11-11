Template.transcriptDetail.onCreated () ->
  self = this
  @autorun () ->
    Session.set "transcriptHtml", undefined
    transcriptId = FlowRouter.getParam('transcriptId')
    subscription = Meteor.subscribe "transcript", transcriptId, {
      onReady: () ->
        console.log "transcriptDetail autorun subscribed to 'transcript' #{transcriptId} publications"

        # Convert XML to HTML using the transcript document service
        t = transcript()
        HTTP.post Meteor.settings.public.transcriptToHtmlURL, {headers: { "Content-Type":"application/x-www-form-urlencoded" }, params: {"doc": t.pescCollegeTranscriptXML}}, (error, response) ->
          console.log "error:"+error
          console.log "response:"+response
          Session.set "transcriptHtml", response.content unless response == undefined

        # See https://meteor.hackpad.com/Blaze-Proposals-for-v0.2-hsd54WPJmDV  and https://meteorhacks.com/kadira-blaze-hooks
        Deps.afterFlush () ->
          console.log "afterFlush following subscribe ready, DOM should exist "
          $('[data-role="page"]').trigger("create")
    }
    if (subscription.ready())
      console.log "subscription ready!"
      Deps.afterFlush () ->
        console.log "afterFlush following subscribe ready, DOM should exist "
        $('[data-role="page"]').trigger("create")
    else
      console.log "subscription not ready!"

transcript = () ->
  transcriptId = FlowRouter.getParam('transcriptId')
  return Transcript.documents.findOne(transcriptId) || {}

Template.transcriptDetail.helpers
  transcript: () ->
    return transcript()

  transcriptHtml: () ->
    return Session.get "transcriptHtml"

Template.transcriptDetail.events =
  'click .review-complete': (e) ->
    console.log "User completed review of transcript: #{this._id}"
    Meteor.call "completeReview", this._id
    FlowRouter.go "transcriptReviewList"

  'click .cancel-review': (e) ->
    console.log "User cancelled review of transcript: #{this._id}"
    Meteor.call "cancelReview", this._id
    FlowRouter.go "transcriptReviewList"


BlazeLayout.setRoot '#page'
transcriptReviewRouter = FlowRouter.group {prefix: "/transcriptReview"}

transcriptReviewRouter.route '/', {
  name: 'transcriptReviewList'
  action: () ->
    console.log "Rendering transcript review list"
    BlazeLayout.render "transcriptsMainLayout", {content: "transcriptList"}
}

Tracker.autorun () ->
  FlowRouter.watchPathChange()
  console.log "route:" + FlowRouter.current()?.route?.name
#  FlowRouter.go FlowRouter.current().route.name

transcriptReviewRouter.route '/:transcriptId', {
  name: 'transcriptReviewDetail',
  action: (params) ->
    console.log "Reviewing transcript:", params.transcriptId
    BlazeLayout.render "transcriptsMainLayout", {content: "transcriptDetail"}
}
