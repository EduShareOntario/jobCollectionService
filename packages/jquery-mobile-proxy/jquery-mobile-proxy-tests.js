// Import Tinytest from the tinytest Meteor package.
import { Tinytest } from "meteor/tinytest";

// Import and rename a variable exported by jquery-mobile-proxy.js.
import { name as packageName } from "meteor/jquery-mobile-proxy";

// Write your tests here!
// Here is an example.
Tinytest.add('jquery-mobile-proxy - example', function (test) {
  test.equal(packageName, "jquery-mobile-proxy");
});
