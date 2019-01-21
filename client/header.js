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
