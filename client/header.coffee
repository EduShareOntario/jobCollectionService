Template.header.events = {
  'click button[name="logout"]': (e) ->
    Session.set 'redirectAfterLogin', null
    Meteor.logout()
    Meteor.logoutOtherClients()
    FlowRouter.go 'login'
}
