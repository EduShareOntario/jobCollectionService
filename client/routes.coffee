BlazeLayout.setRoot '#page'

exposed = FlowRouter.group {}
exposed.route '/login', {
  name: 'login',
  action: () ->
    BlazeLayout.render "login"
}
exposed.route '/unauthorized', {
  name: 'unauthorized',
  action: () ->
    BlazeLayout.render "transcriptsMain", {content: "unauthorized"}
}
exposed.route '/logout', {
  name: 'logout',
  action: () ->
    Session.set 'redirectAfterLogin', null
    Meteor.logoutOtherClients()
    Meteor.logout()
    FlowRouter.redirect '/login'
}

# Before going to any route that is part of this route group, make sure the user is logged in!
ensureLoggedIn = (context, redirect, stop) ->
  unless Meteor.loggingIn() or Meteor.userId()
    routeName = FlowRouter.getRouteName()
    # remember where they want to go!
    unless routeName is 'login'
      Session.set 'redirectAfterLogin', FlowRouter.current().path
    console.log "ensureLoggedIn redirecting to /login"
    redirect '/login'

ensurePermitted = (context, redirect, stop) ->
  unless Meteor.loggingIn() or Meteor.user()?.memberOf?.length > 0
    console.log "ensurePermitted redirecting to /login"
    redirect '/login'

privateRoutes = FlowRouter.group {
  name: 'private',
  triggersEnter: [ensureLoggedIn]
}

#Force evaluation of route when user object changes.
Deps.autorun () ->
  userId = Meteor.userId()
  currentRouteName = FlowRouter.getRouteName()
  console.log "autorun with currentRoute #{currentRouteName} and userId #{userId}"
#  FlowRouter.reload() unless currentRouteName is undefined

# After successful login, redirect the user to the route they originally tried.
Accounts.onLogin ->
  redirectRoutePath = (Session.get 'redirectAfterLogin') or FlowRouter.path('transcriptReviewList')
  console.log "Accounts onLogin with currentRoute #{FlowRouter.getRouteName()}, and redirectAfterLogin #{redirectRoutePath}"
  Session.set 'redirectAfterLogin', null
  FlowRouter.redirect redirectRoutePath

privateRoutes.route '/', {
  name: 'transcriptReviewList'
  action: () ->
    console.log "Rendering transcript review list"
    BlazeLayout.render "transcriptsMain", {content: "transcriptList"}
}
privateRoutes.route '/:transcriptId', {
  name: 'transcriptReviewDetail',
  action: (params) ->
    console.log "Reviewing transcript:", params.transcriptId
    BlazeLayout.render "transcriptsMain", {content: "transcriptDetail"}
}
