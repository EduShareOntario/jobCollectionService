if (Meteor.isServer) {
  var jobCollection;
  var jobCollections = [];
  Meteor.settings.jobCollections.forEach(function (jobCollectionConfig) {
    jobCollection = JobCollection(jobCollectionConfig.name);
    jobCollections.push(jobCollection);
    jobCollection.allow( {
      admin: function(userid, method, params) {
        console.log(userid);
        return jobCollectionConfig.adminUserIds.indexOf(userid != -1);
      }
    })
  });

  Meteor.startup(function () {
    // Normal Meteor publish call, the server always
    // controls what each client can see

    jobCollections.forEach(function(jobCollection) {
      //todo: Publish the job collections for clients to subscribe to.
      //Meteor.publish('all' + jobCollection.name, function() {
      //  return jobCollection.find({});
      //});

      // Start the job queue running
      return jobCollection.startJobServer();
    });

  });}
