/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import {Template} from 'meteor/templating';
import './authStatus.html';

Template.authStatus.helpers({
    onLoginPage() {
        return FlowRouter.getRouteName() === "login";
    }
});

Template.authStatus.events = {
    'click button[name="gotoLogin"]'(e) {
        return FlowRouter.go('login');
    }
};
