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
          HTTP.post Meteor.settings.public.transcriptToHtmlURL, {headers: { "Content-Type":"application/x-www-form-urlencoded" }, params: {"doc": t.pescCollegeTranscriptXML}}, (error, response) ->
            # Update the reactive state to trigger the view to generate!
            template.transcriptHtml.set(response.content)
        else
          template.transcriptHtml.set("<h2>Transcript #{transcriptId} not found</h2>")
    }

Template.transcriptDetail.onRendered () ->
  template = this
  # See https://meteor.hackpad.com/Blaze-Proposals-for-v0.2-hsd54WPJmDV  and https://meteorhacks.com/kadira-blaze-hooks
  template.autorun () ->
    # Watching the path change makes this autorun whenever the path changes!
    # See http://docs.meteor.com/#/full/template_helpers
    FlowRouter.watchPathChange()
    Deps.afterFlush ->
      console.log "transcriptDetail rendered"
      $(template.firstNode.parentElement).trigger("create")
      transcriptId = FlowRouter.getParam('transcriptId')
      t = getTranscript(transcriptId)
      startReviewNeeded = t.awaitingReview()
      console.log "transcript awaitingReview:#{startReviewNeeded}"
      Meteor.call "startReview", t._id if startReviewNeeded

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
