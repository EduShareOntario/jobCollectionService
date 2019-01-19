Template.registerHelper 'addKeys', (all) ->
  return _.map all, (i, k) ->
    return {key: k, value: i}

Template.transcriptsMain.onRendered () ->
  template = this;
  Deps.afterFlush () ->
    console.log("triggering Jquery mobile component creation for "+template.view.name)
    $(template.firstNode.parentElement).trigger "create"
