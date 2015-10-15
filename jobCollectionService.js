function createJobCollections(jobCollectionConfigs) {
  var jobCollections = [];
  var jobCollection;
  if (jobCollectionConfigs) {
    jobCollectionConfigs.forEach(function (jobCollectionConfig) {
      jobCollection = new JobCollection(jobCollectionConfig.name);
      jobCollections.push(jobCollection);
      if (Meteor.isServer) {
        jobCollection.allow( {
          admin: function(userid, method, params) {
            console.log(userid);
            return jobCollectionConfig.adminUserIds.indexOf(userid != -1);
          }
        });
      }
    });
  } else {
    JobCollections = [];
    console.log("Missing jobCollections object.  Make sure METEOR_SETTINGS is configured with the desired jobCollections");
  }
  return jobCollections;
}

var JobCollections;
var Transcripts;

if (Meteor.isServer) {
  // Create our collections.
  JobCollections = createJobCollections(Meteor.settings.jobCollections);

  Meteor.startup(function () {
    // Normal Meteor publish call, the server always controls what each client can see
    JobCollections.forEach(function(jobCollection) {
      Meteor.publish(jobCollection.name, function() {
        jobCollection.find({});
      });
      // Start the job queue running
      jobCollection.startJobServer();
    });
    Meteor.publish('transcripts', function() {
      Transcript.documents.find();
    });

    // todo: remove this insert
    Transcript.documents.insert({"title": "test2 transcript", "description": "wow", "pescCollegeTranscriptXML" :"<doc>blah</doc>"});
    Transcript.documents.insert({"title": "ROBIN2 test transcript", "description": "wow"});

  });
}

if (Meteor.isClient) {
  JobCollections = createJobCollections(Meteor.settings.public ? Meteor.settings.public.jobCollections : undefined);

  Meteor.startup(function(){
    JobCollections.forEach(function(jobCollection) {
      Meteor.subscribe(jobCollection.name);
    });
    return Meteor.subscribe('transcripts');
  });
}
