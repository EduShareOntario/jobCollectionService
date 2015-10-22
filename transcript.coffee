DefaultIdGenerator = {idGenerator:'MONGO'}

class Described extends Document
  title: ""
  description: ""
  @Meta
    abstract: true

class Transcript extends Described
  # Other fields
  pescCollegeTranscriptXML: undefined
  pescCollegeTranscript: undefined
  reviewComplete: false
  reviewedBy: undefined
  @Meta
    name: 'Transcript'
    #wrap existing Meteor collection so we can attach schema validation
    collection: new Meteor.Collection('Transcript', DefaultIdGenerator)
    fields: (fields) =>
      fields.pescCollegeTranscript = @GeneratedField 'self', ['pescCollegeTranscriptXML'], (fields) ->
        #Must return a selector that identifies the document to update and the new value
        unless fields.pescCollegeTranscriptXML
          [fields._id, undefined]
        else
          object = xml2js.parseStringSync(fields.pescCollegeTranscriptXML,{ attrkey: '@',  xmlns: false, ignoreAttrs: true, explicitArray: false, tagNameProcessors: [xml2js.processors.stripPrefix] })
          console.log("1 in generatedField "+fields.pescCollegeTranscriptXML + "\nobject:" + JSON.stringify(object))
          [fields._id, object]

      fields

@Schemas = {}

@Schemas.Described = new SimpleSchema {
  title:
    type: String
  description:
    type: String
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
  reviewComplete:
    type: Boolean
    optional: true
}])
# The Collection2 package will take care of validating a document on save when a 'schema' is associated with the collection.
#todo: this isn't working properly. All object types (eg. student, pescCollegeTranscript) are resulting in empty objects.
Transcript.Meta.collection.attachSchema Schemas.Transcript

@Transcript = Transcript

Meteor.methods
  completeReview: (transcriptId) ->
    #todo: add real access control logic!!
    #if (this.userId) {
    transcript = Transcript.documents.exists({_id:transcriptId});
    console.log("completeReview for transcript:" + transcript);
    Transcript.documents.update({_id:transcriptId}, { $set: {reviewComplete:true}});
