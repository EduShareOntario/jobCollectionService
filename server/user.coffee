Meteor.startup () ->
  Meteor.publish "userData", (userId) ->
    return User.documents.find { _id: this.userId }, { fields: {"department":1, "displayName":1, "givenName":1, "mail":1, "memberOf":1, "title":1} }

  Meteor.users.deny {
    update: () ->
      return true
    insert: () ->
      return true
    remove: () ->
      return true
  }