BlazeLayout.setRoot '#page'

exposed = FlowRouter.group {}
exposed.route '/login', {
  name: 'login',
  action: () ->
    BlazeLayout.render "transcriptsMainLayout", {content: "login"}
}
exposed.route '/unauthorized', {
  name: 'unauthorized',
  action: () ->
    BlazeLayout.render "transcriptsMainLayout", {content: "unauthorized"}
}

# Before going to any route that is part of this route group, make sure the user is logged in!
ensureLoggedIn = () ->
  unless Meteor.loggingIn() or Meteor.userId()
    route = FlowRouter.current()
    # remember where they want to go!
    unless route.route.name is 'login'
      Session.set 'redirectAfterLogin', route.path
    FlowRouter.go 'login'

ensurePermitted = () ->
  unless Meteor.user()?.memberOf?.length > 0
    FlowRouter.go 'unauthorized'

privateRoutes = FlowRouter.group {
  name: 'private',
  triggersEnter: [ensureLoggedIn, ensurePermitted]
}

# After successful login, redirect the user to the route they originally tried.
Accounts.onLogin ->
  redirect = Session.get 'redirectAfterLogin'
  if redirect?
    unless redirect is '/login'
      FlowRouter.go redirect

privateRoutes.route '/transcript', {
  name: 'transcriptReviewList'
  action: () ->
    #console.log "Rendering transcript review list"
    BlazeLayout.render "transcriptsMainLayout", {content: "transcriptList"}
}
privateRoutes.route '/transcript/:transcriptId', {
  name: 'transcriptReviewDetail',
  action: (params) ->
    #console.log "Reviewing transcript:", params.transcriptId
    BlazeLayout.render "transcriptsMainLayout", {content: "transcriptDetail"}
}
