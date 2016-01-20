DefaultIdGenerator = {idGenerator:'MONGO'}

class Described extends Document
#  title: ""
#  description: ""
#  created: undefined
  @Meta
    abstract: true

class Transcript extends Described
#  pescCollegeTranscriptXML: undefined
#  pescCollegeTranscript: undefined
#  reviewStartedOn: undefined
#  reviewCompletedOn: undefined
#  reviewer: undefined
#  reviewer2: undefined
  fullName: () ->
    name = @pescCollegeTranscript.CollegeTranscript.Student.Person.Name
    return name.FirstName + ' ' + name.LastName

  transcriptXmlDump: () ->
    return @pescCollegeTranscriptXML

  transcriptJsonDump: () ->
    return JSON.stringify @pescCollegeTranscript, null, '\t'

  awaitingReview: () ->
    return @reviewCompletedOn == undefined  && @reviewer == undefined

  reviewable: () ->
    return (undefined == @reviewer || @reviewerIsMe()) && @reviewCompletedOn == undefined

  reviewerIsMe: () ->
    return @reviewer == Meteor.userId()

  @Meta
    name: 'Transcript'
    #wrap existing Meteor collection so we can attach schema validation
    collection: new Meteor.Collection 'Transcript', DefaultIdGenerator
    fields: (fields) =>
      fields.pescCollegeTranscript = @GeneratedField 'self', ['pescCollegeTranscriptXML'], (fields) ->
        #Must return a selector that identifies the document to update and the new value
        unless fields.pescCollegeTranscriptXML
          [fields._id, undefined]
        else
          object = xml2js.parseStringSync fields.pescCollegeTranscriptXML,{ attrkey: '@',  xmlns: false, ignoreAttrs: true, explicitArray: false, tagNameProcessors: [xml2js.processors.stripPrefix] }
#          console.log "in generatedField "+fields.pescCollegeTranscriptXML + "\nobject:" + JSON.stringify(object)
          [fields._id, object]

      fields.ocasRequestId = @GeneratedField 'self', ['pescCollegeTranscript'], (fields) ->
        unless fields.pescCollegeTranscript
          [fields._id, undefined]
        else
          object = fields.pescCollegeTranscript.CollegeTranscript.TransmissionData.RequestTrackingID
          [fields._id, object]

      fields.reviewer2 = @ReferenceField User, false

      fields


@Schemas = {}

@Schemas.Described = new SimpleSchema {
  title:
    type: String
  description:
    type: String
  created:
    type: Date
    defaultValue: new Date()
    denyUpdate: true
  # Define a placeholder for the PeerDB _schema field as this is required for the 'migrations' feature.
  _schema:
    type: String
    optional: true
}

@Schemas.Transcript = new SimpleSchema([@Schemas.Described, {
  pescCollegeTranscriptXML:
    type: String
    optional: true
  pescCollegeTranscript:
    type: Object
    optional: true
    blackbox: true
  ocasRequestId:
    type: String
    optional: true
  reviewStartedOn:
    type: Date
    optional: true
  reviewCompletedOn:
    type: Date
    optional: true
  reviewer:
    type: String
    optional: true
  reviewer2:
    type: @User
    optional: true
    blackbox: true
  applicant:
    type: Object
    optional: true
    blackbox: true
}])

@Schemas.Applicant = new SimpleSchema {

}
# The Collection2 package will take care of validating a document on save when a 'schema' is associated with the collection.
Transcript.Meta.collection.attachSchema Schemas.Transcript
Transcript.Meta.collection._ensureIndex ocasRequestId: 1, created: 1 unless Meteor.isClient
Transcript.Meta.collection._ensureIndex reviewCompletedOn: 1 unless Meteor.isClient

@Transcript = Transcript

Meteor.methods
  completeReview: (transcriptId) ->
    user = Meteor.user()
    throw new Meteor.Error(403, "Access denied") unless user?.memberOf?.length > 0
    exists = Transcript.documents.exists({_id:transcriptId})
    if (exists)
      console.log "#{user._id}, #{user.dn} : completeReview for transcript:" + transcriptId
      Transcript.documents.update({_id:transcriptId, reviewCompletedOn:null}, { $set: {reviewCompletedOn: new Date(), reviewer:Meteor.userId(), reviewer2:Meteor.user()}})
    else
      console.log "#{user._id}, #{user.dn} : completeReview failed for transcript:" + transcriptId + " ; a document with this id does not exist!"

  startReview: (transcriptId) ->
    user = Meteor.user()
    throw new Meteor.Error(403, "Access denied") unless user?.memberOf?.length > 0
    console.log "#{user._id}, #{user.dn} : startReview for transcript:" + transcriptId
    Transcript.documents.update({_id:transcriptId, reviewCompletedOn:null}, { $set: {reviewStartedOn: new Date(), reviewer:Meteor.userId(), reviewer2:Meteor.user()}})

  cancelReview: (transcriptId) ->
    user = Meteor.user()
    throw new Meteor.Error(403, "Access denied") unless user?.memberOf?.length > 0
    console.log "#{user._id}, #{user.dn} : cancelReview for transcript:" + transcriptId
    Transcript.documents.update({_id:transcriptId, reviewCompletedOn:null}, { $unset: {reviewStartedOn: "", reviewer:"", reviewer2:""}})
