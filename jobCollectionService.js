function createJob(jobCollection, jobType) {
  var exists = (jobCollection.find({type:jobType}).count() > 0);
  if (!exists) {
    var job = new Job(jobCollection.root, jobType, {});
    job.priority('normal');
    job.retry({ retries: Job.forever, wait: 15 * 60 * 1000 });
    job.repeat({ repeats: Job.forever });
    job.save();
    //todo:  handle save failure!!
  }
}

function createJobCollections(jobCollectionConfigs) {
  var jobCollections = {};
  var jobCollection;
  if (jobCollectionConfigs) {
    jobCollectionConfigs.forEach(function (jobCollectionConfig) {
      jobCollection = new JobCollection(jobCollectionConfig.name);
      jobCollections[jobCollectionConfig.name] = jobCollection;
      if (Meteor.isServer) {
        jobCollection.allow( {
          admin: function(userid, method, params) {
            allow = (jobCollectionConfig.adminUserIds.indexOf(userid) != -1);
            console.log("jobCollection "+jobCollectionConfig.name+": checking user "+userid+" allowed was "+allow);
            return (jobCollectionConfig.adminUserIds.indexOf(userid) != -1);
          }
        });
        _.each(jobCollectionConfig.scheduledJobs, function (jobType) {
          createJob(jobCollection, jobType);
        });
      }
    });
  } else {
    jobCollections = [];
    console.log("Missing jobCollections object.  Make sure METEOR_SETTINGS is configured with the desired jobCollections.");
  }
  return jobCollections;
}

// App scoped!
JobCollections = {};

if (Meteor.isServer) {
  // Create our collections.
  JobCollections = createJobCollections(Meteor.settings.jobCollections);

  Meteor.startup(function () {
    _.each(JobCollections, function(jobCollection, name) {
      // Start the job queue running
      jobCollection.startJobServer();
      console.log("started job server "+name);

      //Ready jobs that are waiting.
      //Jobs go into a waiting state when they have been running too long as specified by workTimeout.
      // We want to automate returning them to a ready state!
      Job.processJobs(jobCollection.root, 'readyJobs', {workTimeout: 60*1000}, function(job,cb){
        Job.readyJobs(job.root);
        job.done();
        cb();
      });
    });
  });
}

