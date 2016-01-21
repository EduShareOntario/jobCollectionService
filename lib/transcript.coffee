DefaultIdGenerator = { idGenerator:'MONGO' }

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
    return @reviewer?._id == Meteor.userId()

  myId: () ->
    return @__originalId || @_id

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

      fields.reviewer = @ReferenceField User, ['mail', 'displayName']

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

if (Meteor.isServer)
  Transcript.Meta.collection._ensureIndex ocasRequestId: 1, created: 1
  Transcript.Meta.collection._ensureIndex reviewCompletedOn: 1
  #Transcript.Meta.collection._ensureIndex { title: 'text', description: 'text', pescCollegeTranscriptXML: 'text', 'reviewer.displayName': 'text', ocasRequestId: 'text', 'applicant.studentId': 'text', 'applicant.termCode': 'text'}, {background: true, name: 'search'} unless Meteor.isClient

#EasySearch takes care of client and server initialization differences!
@TranscriptIndex = new EasySearch.Index
  name: 'transcriptIndex'
  #todo: Fix MongoTextIndex to support more text fields or enusreIndex callback
  #  fields: ['title','description','pescCollegeTranscriptXML','reviewer.displayName','ocasRequestId','applicant.studentId','applicant.termCode']
  fields: ['title', 'description','pescCollegeTranscriptXML']
  defaultSearchOptions: {score: {$meta: "textScore"}, sort: {score: {$meta: "textScore"}}, limit: 50, props: { searchFilter: 'pendingReview' }}
  #todo: Enhance EasySearch.MongoTextIndex to support ensureIndex with {background: true, name: 'search'}
  engine: new EasySearch.MongoTextIndex {
    transform: (doc) ->
      return new Transcript doc
    selector: (searchObject, options, aggregation) ->
      console.log searchObject
      console.log options
      console.log aggregation
      selector =  this.defaultConfiguration().selector searchObject, options, aggregation
      switch options.search.props.searchFilter
        when "pendingReview"
          selector.reviewCompletedOn = undefined
          selector.applicant = {$ne:null}
        when "reviewedByMe"
          selector['reviewer._id'] = options.search.userId
        when "reviewed"
          selector.reviewer = {$ne:null}

      return selector
  }
  collection: Transcript.Meta.collection
  permission: (options) ->
    return options.userId # only allow searching when the user is logged in

@Transcript = Transcript

Meteor.methods
  completeReview: (transcriptId) ->
    user = Meteor.user()
    throw new Meteor.Error(403, "Access denied") unless user?.memberOf?.length > 0
    exists = Transcript.documents.exists({_id:transcriptId})
    if (exists)
      console.log "#{user._id}, #{user.dn} : completeReview for transcript:" + transcriptId
      Transcript.documents.update({_id:transcriptId, reviewCompletedOn:null, 'reviewer._id':user._id}, { $set: {reviewCompletedOn: new Date(), 'reviewer._id':user._id}})
    else
      console.log "#{user._id}, #{user.dn} : completeReview failed for transcript:" + transcriptId + " ; a document with this id does not exist!"

  startReview: (transcriptId) ->
    user = Meteor.user()
    throw new Meteor.Error(403, "Access denied") unless user?.memberOf?.length > 0
    console.log "#{user._id}, #{user.dn} : startReview for transcript:" + transcriptId
    Transcript.documents.update({_id:transcriptId, reviewCompletedOn:null}, { $set: {reviewStartedOn: new Date(), 'reviewer._id':user._id}})

  cancelReview: (transcriptId) ->
    user = Meteor.user()
    throw new Meteor.Error(403, "Access denied") unless user?.memberOf?.length > 0
    console.log "#{user._id}, #{user.dn} : cancelReview for transcript:" + transcriptId
    Transcript.documents.update({_id:transcriptId, reviewCompletedOn:null, 'reviewer._id':user._id}, { $unset: {reviewStartedOn: "", reviewer:""}})
