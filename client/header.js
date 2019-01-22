/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import {Template} from 'meteor/templating';

import './header.html';
import './header.css';

Template.header.events = {
    'click button[name="logout"]'(e) {
        return FlowRouter.go('logout');
    }
};

Template.header.onRendered(function () {
    const template = this;
    return Tracker.afterFlush(function () {
        console.log(`triggering Jquery mobile component creation for ${template.view.name}`);
        return $('body').trigger("create");
    });
});

