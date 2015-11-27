Template.authStatus.helpers
  onLoginPage: ->
    return FlowRouter.getRouteName() == "login"

Template.authStatus.events = {
  'click button[name="gotoLogin"]': (e) ->
    FlowRouter.go 'login'
}

Template.authStatus.onRendered ()->
  console.log "authStatus rendered"
  $(this.firstNode.parentElement).trigger("create")
