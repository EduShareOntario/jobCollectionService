Template.authStatus.helpers
  onLoginPage: ->
    return FlowRouter.getRouteName() == "login"

Template.authStatus.events = {
  'click button[name="gotoLogin"]': (e) ->
    FlowRouter.go 'login'
}
