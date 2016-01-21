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
  console.log "ensureLoggedIn called"
  routeName = FlowRouter.getRouteName()
  unless routeName is 'login'
    # remember where they want to go!
    currentPath = FlowRouter.current().path
    console.log "Saving redirectAfterLogin to #{currentPath}"
    Session.set 'redirectAfterLogin', currentPath
    unless Auth.ready() or Auth.authenticating()
      console.log "ensureLoggedIn redirecting to /login"
      redirect '/login'

privateRoutes = FlowRouter.group {
  name: 'private',
  triggersEnter: [ensureLoggedIn]
}

#Force evaluation of route when user object changes.
Deps.autorun () ->
  userId = Meteor.userId()
  currentRouteName = FlowRouter.getRouteName()
  redirectRoutePath = Session.get 'redirectAfterLogin'
  console.log "Current Route or session redirectAfterLogin changed: currentRouteName #{currentRouteName}, redirectAfterLogin is #{redirectRoutePath} and userId #{userId}"

# After successful login, redirect the user to the route they originally tried.
Accounts.onLogin ->
  redirectRoutePath = Session.get 'redirectAfterLogin'
  console.log "Accounts onLogin with currentRoute #{FlowRouter.getRouteName()}, and redirectAfterLogin #{redirectRoutePath}"
  Session.set 'redirectAfterLogin', null
  FlowRouter.redirect redirectRoutePath

privateRoutes.route '/review', {
  name: 'transcriptReviewList'
  action: () ->
    console.log "Rendering transcript review list"
    BlazeLayout.render "transcriptsMain", {content: "transcriptList"}
}
privateRoutes.route '/review/:transcriptId', {
  name: 'transcriptReviewDetail',
  action: (params) ->
    console.log "Reviewing transcript:", params.transcriptId
    BlazeLayout.render "transcriptsMain", {content: "transcriptDetail"}
}
privateRoutes.route '/search', {
  name: 'transcriptSearch'
  action: () ->
    console.log "Rendering transcript search"
    BlazeLayout.render "transcriptsMain", {content: "transcriptSearch"}
}
