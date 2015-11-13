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
    jobCollections = [];
    console.log("Missing jobCollections object.  Make sure METEOR_SETTINGS is configured with the desired jobCollections.");
  }
  return jobCollections;
}

var JobCollections;

if (Meteor.isServer) {
  // Create our collections.
  JobCollections = createJobCollections(Meteor.settings.jobCollections);

  Meteor.startup(function () {
    // Normal Meteor publish call, the server always controls what each client can see
    JobCollections.forEach(function(jobCollection) {
      Meteor.publish(jobCollection.name, function() {
        return jobCollection.find({});
      });
      // Start the job queue running
      jobCollection.startJobServer();
    });
  });

}

//if (Meteor.isClient) {
//  JobCollections = createJobCollections(Meteor.settings.public ? Meteor.settings.public.jobCollections : undefined);
//
//  Meteor.startup(function(){
//    JobCollections.forEach(function(jobCollection) {
//      Meteor.subscribe(jobCollection.root);
//    });
//  });
//}
