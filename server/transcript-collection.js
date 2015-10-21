Meteor.publish('transcripts', function() {
  return Transcript.documents.find();
});

// Before observers are enabled.
// Caution: Generated fields 'observe' changes and hence won't get generated at this phase!!!
Document.prepare(function() {
  console.log("prepare says 'helloooo todd'");
});

// After Meteor startup, including peerdb observers getting enabled.
Document.startup(function() {
  //todo: remove this insert
  SimpleSchema.debug = true;
  Transcript.documents.insert({"title": "startup: 32test transcript", "description": "wow23333d", "pescCollegeTranscriptXML" :"", ocasApplication: {id:'1234',name:'todd'}});
  console.log("startup says 'hello todd'");
  _(Transcript.documents.find({}).fetch()).each(function(transcipt){
    console.log(transcipt);
  });
  Document.updateAll();
});
