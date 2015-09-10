///////////////////
// node.js Worker
var DDP = require('ddp');
var DDPlogin = require('ddp-login');
var Job = require('meteor-job');

// `Job` here has essentially the same API as JobCollection on Meteor.
// In fact, job-collection is built on top of the 'meteor-job' npm package!

// Setup the DDP connection
var ddp = new DDP({
  host: "localhost",
  port: 3000,
  use_ejson: true
});
var loginOptions = {
  env: 'METEOR_TOKEN',  // Name of an environment variable to check for a
  // token. If a token is found and is good,
  // authentication will require no user interaction.
  method: 'account',    // Login method: account, email, username or token
  account: null,        // Prompt for account info by default
  pass: null,           // Prompt for password by default
  retry: 5,             // Number of login attempts to make
  plaintext: false      // Do not fallback to plaintext password compatibility
                        // for older non-bcrypt accounts
}

// Connect Job with this DDP session
Job.setDDP(ddp);

// Open the DDP connection
ddp.connect(function (err) {
  if (err) throw err;
  // Call below will prompt for email/password if an
  // authToken isn't available in the process environment
  DDPlogin(ddp, loginOptions, function (err, token) {
    if (err) throw err;
    // We're in!
    // Create a job:
    var job = new Job('student-transcript', 'storeTranscript', // type of job
        // Job data that you define, including anything the job
        // needs to complete. May contain links to files, etc...
        {
          transriptDocument: '<blah>oops</blah>',
          studentId: '1234'
        }
    );

    // Set some properties of the job and then submit it
    job.priority('normal')
        .retry({
          retries: 5,
          wait: 1 * 60 * 1000
        })  // 1 minutes between attempts
        .save(function (err, result) {
          if (!err && result) {
            console.log("New job saved with Id: " + result);
          } else {
            console.log(err);
          }
          ddp.close();
          process.exit();
        }); // Commit it to the server
  });
});
