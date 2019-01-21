import {JobCollections} from "./JobCollections";

Meteor.startup(function () {
    _.each(JobCollections, function (jobCollection, name) {
        // Start the job queue running
        jobCollection.startJobServer();
        console.log("started job server " + name);

        //Ready jobs that are waiting.
        //Jobs go into a waiting state when they have been running too long as specified by workTimeout.
        // We want to automate returning them to a ready state!
        new Job.processJobs(jobCollection.root, 'readyJobs', {workTimeout: 60 * 1000}, function (job, cb) {
            new Job.readyJobs(job.root);
            job.done();
            cb();
        });
    });
});
