Meteor.startup () ->
  Meteor.publish "userData", () ->
    return Meteor.users.find { _id: this.userId }
