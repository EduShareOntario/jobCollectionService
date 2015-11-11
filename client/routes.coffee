BlazeLayout.setRoot '#page'

transcriptReviewRouter = FlowRouter.group {prefix: "/transcriptReview"}

transcriptReviewRouter.route '/', {
  name: 'transcriptReviewList'
  action: () ->
#console.log "Rendering transcript review list"
    BlazeLayout.render "transcriptsMainLayout", {content: "transcriptList"}
}

transcriptReviewRouter.route '/:transcriptId', {
  name: 'transcriptReviewDetail',
  action: (params) ->
    console.log "Reviewing transcript:", params.transcriptId
    BlazeLayout.render "transcriptsMainLayout", {content: "transcriptDetail"}
}
