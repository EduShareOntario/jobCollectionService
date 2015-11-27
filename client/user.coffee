Deps.autorun () ->
  userId = Meteor.userId()
  if userId
    Meteor.subscribe "userData", userId
    console.log "subscribed to userData for userId #{userId}"
