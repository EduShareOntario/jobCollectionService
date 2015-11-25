Template.registerHelper 'addKeys', (all) ->
  return _.map all, (i, k) ->
    return {key: k, value: i}

Template.transcriptsMain.onRendered () ->
  template = this
  # See https://meteor.hackpad.com/Blaze-Proposals-for-v0.2-hsd54WPJmDV  and https://meteorhacks.com/kadira-blaze-hooks
  template.autorun () ->
    # Watching the path change makes this autorun whenever the path changes!
    # See http://docs.meteor.com/#/full/template_helpers
    FlowRouter.watchPathChange()
    Deps.afterFlush ->
      console.log "transcriptsMain rendered"
      $(template.firstNode.parentElement).trigger("create")
