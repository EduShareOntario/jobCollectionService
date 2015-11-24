Template.header.events = {
  'click button[name="logout"]': (e) ->
    FlowRouter.go 'logout'
}
