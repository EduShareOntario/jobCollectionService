Template.transcriptDetail.onCreated () ->
  template = this
  template.transcriptHtml = new ReactiveVar()
  template.autorun () ->
    transcriptId = FlowRouter.getParam('transcriptId')
    template.subscribe "transcript", transcriptId, {
      onReady: () ->
        # Convert XML to HTML using the transcript document service
        t = getTranscript(transcriptId)
        if (t.pescCollegeTranscriptXML)
          startReviewNeeded = t.awaitingReview()
          console.log "startReviewNeeded:#{startReviewNeeded}"
          Meteor.call "startReview", t._id if startReviewNeeded
          HTTP.post Meteor.settings.public.transcriptToHtmlURL, {headers: { "Content-Type":"application/x-www-form-urlencoded" }, params: {"doc": t.pescCollegeTranscriptXML}}, (error, response) ->
            # Update the reactive state to trigger the view to generate!
            template.transcriptHtml.set(response.content)
        else
          template.transcriptHtml.set("<h2>Transcript #{transcriptId} not found</h2>")
    }

getTranscript = (id) ->
  id = getTranscriptId() unless id
  return Transcript.documents.findOne(id) || {}

getTranscriptId = ->
  return FlowRouter.getParam('transcriptId')

Template.transcriptDetail.helpers
  transcript: () ->
    return getTranscript()

  transcriptId: () ->
    return getTranscriptId()

  transcriptHtml: () ->
    return Template.instance().transcriptHtml.get()

  showHtml: () ->
    return true if Template.instance().transcriptHtml.get()

  showXml: () ->
    return true

  showJson: () ->
    return true

Template.transcriptDetail.events =
  'click .review-complete': (e) ->
    #console.log "User completed review of transcript: #{this._id}"
    Meteor.call "completeReview", this._id
    FlowRouter.go "transcriptReviewList"

  'click .review-takeover': (e) ->
    #console.log "User review takeover for transcript: #{this._id}"
    Meteor.call "startReview", this._id

  'click .cancel-review': (e) ->
    #console.log "User cancelled review of transcript: #{this._id}"
    Meteor.call "cancelReview", this._id
    FlowRouter.go "transcriptReviewList"
