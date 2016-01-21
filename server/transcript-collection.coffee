fs = Npm.require 'fs'

Meteor.publish 'pendingReviewTranscripts', (userId) ->
  throw new Meteor.Error(403, "Access denied") unless this.userId
  user = User.documents.findOne this.userId
  throw new Meteor.Error(403, "Access denied") unless user?.memberOf?.length > 0
  this.unblock
  return Transcript.documents.find {reviewCompletedOn:undefined, applicant: {$ne:null}}, {sort: {ocasRequestId:1}}

Meteor.publish 'transcriptSearch', (userId, searchText) ->
  throw new Meteor.Error(403, "Access denied") unless this.userId
  user = User.documents.findOne this.userId
  throw new Meteor.Error(403, "Access denied") unless user?.memberOf?.length > 0
  console.log "transcriptSearch called for user #{user.displayName} with searchText #{searchText}"
  this.unblock
  if searchText
    return Transcript.documents.find {$text: { $search: searchText}}, {score: {$meta: "textScore"}}, {sort: {score: {$meta: "textScore"}}, limit: 100}
  else
    return Transcript.documents.find {}, {sort: {ocasRequestId:1}, limit: 100}

Meteor.publish 'transcript', (transcriptId) ->
  throw new Meteor.Error(403, "Access denied") unless this.userId
  user = User.documents.findOne this.userId
  throw new Meteor.Error(403, "Access denied") unless user?.memberOf?.length > 0
  return Transcript.documents.find {_id: transcriptId}


# Before observers are enabled.
# Caution: Generated fields 'observe' changes and hence won't get generated at this phase!!!
Document.prepare () ->
  console.log("prepare says 'helloooo todd'");

# After Meteor startup, including peerdb observers getting enabled.
Document.startup () ->
  Document.updateAll()

Meteor.methods
  createTestTranscripts: () ->
    user = Meteor.user()
    throw new Meteor.Error(403, "Access denied") unless user?.memberOf?.length > 0

    console.log "createTranscriptsForTesting started by #{user._id}, #{user.dn}"
    testTranscriptDir = "./assets/app/config/testTranscripts/"
    files = fs.readdirSync testTranscriptDir
    _.each files, (file)-> console.log file
    console.log files
    xmlFiles = _.filter files, (file) -> file.match /\.xml$/
    console.log xmlFiles
    _.each xmlFiles, (file) ->
        pescXml = fs.readFileSync testTranscriptDir + file, {encoding: "UTF-8"}
        #SimpleSchema.debug = true
        transcript = new Transcript {"title": "test #{file}", "description": file, "created": new Date() }
        transcript.pescCollegeTranscriptXML = pescXml
        Transcript.documents.insert transcript

    _(Transcript.documents.find({}).fetch()).each (transcipt) ->
      console.log transcipt.title + ":" + transcipt._id
    console.log "createTranscriptsForTesting is done"

  createTranscript: (transcript) ->
    console.log "createTranscript called with #{JSON.stringify(transcript)}"
    user = Meteor.user()
    throw new Meteor.Error(403, "Access denied") unless 'batch job' in user?.memberOf? or user?.batchJobRunner
    transcript = new Transcript(transcript)
    newId = Transcript.documents.insert transcript
    return newId

  getTranscript: (transcriptId) ->
    console.log "getTranscript called with #{JSON.stringify(transcriptId)}"
    user = Meteor.user()
    throw new Meteor.Error(403, "Access denied") unless 'batch job' in user?.memberOf? or user?.batchJobRunner
    transcript = Transcript.documents.findOne(transcriptId)
    #console.log "transcript is #{transcript}"
    return transcript

  setApplicant: (transcriptId, applicant) ->
    console.log "setApplicant called with transcriptId #{transcriptId} and applicant #{JSON.stringify(applicant)}"
    user = Meteor.user()
    throw new Meteor.Error(403, "Access denied") unless 'batch job' in user?.memberOf? or user?.batchJobRunner
    Transcript.documents.update {_id:transcriptId}, { $set:{applicant: applicant} }
    return true

  #
  # Example use:
  # ddpClient.call("findRedundantJobs", [createJobConfig.root, {"data.ocasRequestId": {$in: requestIds}, status: {$ne: "failed"}}, {"data.ocasRequestId": 1}], function (err, redundantJobs) { ...}
  findRedundantJobs: (jobCollectionName, redundantSelector, resultFields) ->
    #console.log "findRedundantJobs called with jobCollectionName #{jobCollectionName}, redundantSelector #{JSON.stringify(redundantSelector)} and resultFields #{JSON.stringify(resultFields)}"
    user = Meteor.user()
    throw new Meteor.Error(403, "Access denied") unless 'batch job' in user?.memberOf? or user?.batchJobRunner

    jobCollection = JobCollections[jobCollectionName]
    collection = jobCollection._collection
    #console.log "searching Job Collection name:#{jobCollectionName}, object: #{collection}, with keys: #{_.keys(collection unless collection is undefined )}, root:#{jobCollection?.root}, JobCollections:#{JobCollections}, keys:#{_.keys(JobCollections)}"
    result = collection.find redundantSelector, {fields:resultFields} unless collection is undefined
    return result.fetch()

