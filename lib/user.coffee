class User extends @Document
  @Meta
    name: 'User'
    collection: Meteor.users

  isTranscriptReviewer: () ->
    return @memberOf?.length > 0

@User = User
