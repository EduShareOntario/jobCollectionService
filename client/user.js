/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import {Tracker} from 'meteor/tracker';
import {Meteor} from 'meteor/meteor';

Tracker.autorun(function() {
    const userId = Meteor.userId();
    if (userId) {
        Meteor.subscribe("userData", userId);
        return console.log(`subscribed to userData for userId ${userId}`);
    }
});
