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

  transcriptDump: () ->
    return @pescCollegeTranscriptXML

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
          console.log "in generatedField "+fields.pescCollegeTranscriptXML + "\nobject:" + JSON.stringify(object)
          [fields._id, object]

      fields.reviewer2 = @ReferenceField User, false

      fields


class User extends Document
  @Meta
    name: 'User'
    collection: Meteor.users

@Schemas = {}

@Schemas.Described = new SimpleSchema {
  title:
    type: String
  description:
    type: String
  created:
    type: Date
    defaultValue: new Date()
  # Define a placeholder for the PeerDB _schema field as this is required for the 'migrations' feature.
  _schema:
    type: String
    optional: true
}

@Schemas.Transcript = new SimpleSchema([@Schemas.Described, {
  ocasApplication:
    type: Object
    optional: true
    blackbox: true
  pescCollegeTranscriptXML:
    type: String
    optional: true
  pescCollegeTranscript:
    type: Object
    optional: true
    blackbox: true
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
    type: User
    optional: true
    blackbox: true
}])
# The Collection2 package will take care of validating a document on save when a 'schema' is associated with the collection.
#todo: this isn't working properly. All object types (eg. student, pescCollegeTranscript) are resulting in empty objects.
Transcript.Meta.collection.attachSchema Schemas.Transcript

@Transcript = Transcript

Meteor.methods
  completeReview: (transcriptId) ->
    #todo: add real access control logic!!
    if (Meteor.userId())
      exists = Transcript.documents.exists({_id:transcriptId})
      if (exists)
        console.log "completeReview for transcript:" + transcriptId
        Transcript.documents.update({_id:transcriptId}, { $set: {reviewCompletedOn: new Date(), reviewer:Meteor.userId(), reviewer2:Meteor.user()}})
      else
        console.log "completeReview failed for transcript:" + transcriptId + " ; a document with this id does not exist!"

  startReview: (transcriptId) ->
    #todo: add real access control logic!!
    if (Meteor.userId())
      console.log "startReview for transcript:" + transcriptId
      Transcript.documents.update({_id:transcriptId}, { $set: {reviewStartedOn: new Date(), reviewer:Meteor.userId(), reviewer2:Meteor.user()}})

  cancelReview: (transcriptId) ->
    #todo: add real access control logic!!
    if (Meteor.userId())
      console.log "cancelReview for transcript:" + transcriptId
      Transcript.documents.update(_id:transcriptId, { $unset: {reviewStartedOn: "", reviewer:"", reviewer2:""}})
