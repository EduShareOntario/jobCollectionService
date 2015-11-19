Meteor.startup () ->
  Meteor.publish "userData", (userId) ->
    return User.documents.find { _id: this.userId }, { fields: {"department":1, "displayName":1, "givenName":1, "mail":1, "memberOf":1, "notMemberOf":1, "title":1} }

  Meteor.users.deny {
    update: () ->
      return true
    insert: () ->
      return true
    remove: () ->
      return true
  }

# Before observers are enabled.
# Caution: Generated fields 'observe' changes and hence won't get generated at this phase!!!
Document.prepare () ->
  console.log("Preparing user documents with a clean membership! Membership will be reestablished upon successful LDAP login.");
  User.documents.update {}, { $unset: {"memberOf": "", "notMemberOf":""} }, {multi: true}
