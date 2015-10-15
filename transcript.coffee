DefaultIdGenerator = {idGenerator:'MONGO'}
class Described extends Document
  title: ""
  description: ""
  @Meta
    abstract: true

class Transcript extends Described
  # Other fields
  # student
  # pescCollegeTranscriptXML
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
          object = xml2js.parseStringSync(fields.pescCollegeTranscriptXML)
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
  student:
    type: Object
    optional: true
  pescCollegeTranscriptXML:
    type: String
    optional: true
  pescCollegeTranscript:
    type: Object
    optional: true
}])
# The Collection2 package will take care of validating a document on save when a 'schema' is associated with the collection.
Transcript.Meta.collection.attachSchema Schemas.Transcript

@Transcript = Transcript
