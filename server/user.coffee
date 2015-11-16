Meteor.startup () ->
  Meteor.publish "userData", (userId) ->
    return Meteor.users.find { _id: this.userId }
