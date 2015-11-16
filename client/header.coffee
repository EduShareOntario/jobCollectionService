Template.header.events = {
  'click button[name="logout"]': (e)->
    Meteor.logout()
}