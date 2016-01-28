class User extends @Document
  @Meta
    name: 'User'
    collection: Meteor.users

  isTranscriptReviewer: () ->
    return @memberOf?.length > 0

  isTranscriptBatchJobRunner: () ->
    return @isMemberOf('batch job') or user?.batchJobRunner

  isMemberOf: (group) ->
    return group in @memberOf

@User = User
