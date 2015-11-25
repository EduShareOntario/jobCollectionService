class Authorization
  #Global/shared Class variables
  error: new ReactiveVar false
  authenticatingState: new ReactiveVar false

  authorized: () ->
    console.log "Auth.authorized() called"
    return Meteor.user()?.isTranscriptReviewer()

  unauthorized: () ->
    error = Auth.error.get()
    authorized = Auth.authorized()
    redirect = Session.get 'redirectAfterLogin'
    return !error and redirect and !(authorized)

  authenticating: () ->
    return Auth.authenticatingState.get()

  ready: () ->
    Meteor.user()?.username != undefined

  authError: () ->
    return Auth.error.get()

  loginWithLdap2: (username, password) ->
    if username.length == 0 or password.length == 0
      Auth.error.set true
    else
      Auth.authenticatingState.set true
      Auth.error.set false
      Accounts.callLoginMethod {
        methodArguments: [{username: username,pass: password,ldap: true}],
        validateResult: (result) -> ,
        userCallback: (result) ->
          Auth.authenticatingState.set false
          #console.log JSON.stringify(result)
          if (result && result.error)
            Auth.error.set true
      }

@Auth = new Authorization()

# !Important Concept:
# Under the hood, each helper starts a new Tracker.autorun.
# When its reactive dependencies change, the helper is rerun.
# Helpers depend on their data context, passed arguments and other reactive data sources accessed during execution.
# eg. Meteor.user() is a reactive data source!
# See http://docs.meteor.com/#/full/template_helpers
Template.registerHelper "authError", Auth.authError
Template.registerHelper "authorized", Auth.authorized
Template.registerHelper "unauthorized", Auth.unauthorized
Template.registerHelper "authReady", Auth.ready
Template.registerHelper "authenticating", Auth.authenticating

Template.ldapLogin2.events = {
  'click button[name="login2"]': (e, tpl) ->
    initLogin2 e, tpl

  'keyup input': (e, tpl) ->
    if (e.keyCode == 13) #If Enter Key Pressed
      initLogin2 e, tpl
}

# Initiate Login Process:
initLogin2 = (e, tpl) ->
  username = $(tpl.find('input[name="ldap"]')).val().trim();
  password = $(tpl.find('input[name="password"]')).val().trim();
  Auth.loginWithLdap2 username, password


Template.login.onRendered () ->
  template = this
  # See https://meteor.hackpad.com/Blaze-Proposals-for-v0.2-hsd54WPJmDV  and https://meteorhacks.com/kadira-blaze-hooks
  template.autorun () ->
    # Watching the path change makes this autorun whenever the path changes!
    # See http://docs.meteor.com/#/full/template_helpers
    FlowRouter.watchPathChange()
    Deps.afterFlush ->
      console.log "login rendered"
      $(template.firstNode.parentElement).trigger("create")
