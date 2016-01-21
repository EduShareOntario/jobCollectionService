Template.registerHelper 'addKeys', (all) ->
  return _.map all, (i, k) ->
    return {key: k, value: i}
