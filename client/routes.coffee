BlazeLayout.setRoot '#page'

exposed = FlowRouter.group {}
exposed.route '/login', {
  name: 'login',
  action: () ->
    BlazeLayout.render "transcriptsMain", {content: "login"}
}
exposed.route '/unauthorized', {
  name: 'unauthorized',
  action: () ->
    BlazeLayout.render "transcriptsMain", {content: "unauthorized"}
}

# Before going to any route that is part of this route group, make sure the user is logged in!
ensureLoggedIn = () ->
  unless Meteor.loggingIn() or Meteor.userId()
    route = FlowRouter.current()
    # remember where they want to go!
    unless route.route.name is 'login'
      Session.set 'redirectAfterLogin', route.name
    FlowRouter.go 'login'

ensurePermitted = () ->
  unless Meteor.loggingIn() or Meteor.user()?.memberOf?.length > 0
    FlowRouter.go 'login'

privateRoutes = FlowRouter.group {
  name: 'private',
  triggersEnter: [ensureLoggedIn, ensurePermitted]
}

# After successful login, redirect the user to the route they originally tried.
Accounts.onLogin ->
  currentRoute = FlowRouter.current().route
  redirect = (Session.get 'redirectAfterLogin') or 'transcriptReviewList'
  Session.set 'redirectAfterLogin', null
  if currentRoute?.name is redirect
    FlowRouter.reload()
  else
    FlowRouter.go redirect

privateRoutes.route '/transcript', {
  name: 'transcriptReviewList'
  action: () ->
    #console.log "Rendering transcript review list"
    BlazeLayout.render "transcriptsMain", {content: "transcriptList"}
}
privateRoutes.route '/transcript/:transcriptId', {
  name: 'transcriptReviewDetail',
  action: (params) ->
    #console.log "Reviewing transcript:", params.transcriptId
    BlazeLayout.render "transcriptsMain", {content: "transcriptDetail"}
}
