/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import {Template} from 'meteor/templating';
import {Meteor} from 'meteor/meteor';
import {Session} from 'meteor/session';
import {Accounts} from 'meteor/accounts-base';
import {Tracker} from 'meteor/tracker';

import './login.html';

class Authorization {
    static initClass() {
        //Global/shared Class variables
        this.prototype.error = new ReactiveVar(false);
        this.prototype.authenticatingState = new ReactiveVar(false);
    }

    authorized() {
        console.log("Auth.authorized() called");
        return __guard__(Meteor.user(), x => x.isTranscriptReviewer());
    }

    unauthorized() {
        const error = Auth.error.get();
        const authorized = Auth.authorized();
        const redirect = Session.get('redirectAfterLogin');
        return !error && redirect && !(authorized);
    }

    authenticating() {
        return Auth.authenticatingState.get();
    }

    ready() {
        return __guard__(Meteor.user(), x => x.username) !== undefined;
    }

    authError() {
        return Auth.error.get();
    }

    loginWithLdap2(username, password) {
        if ((username.length === 0) || (password.length === 0)) {
            return Auth.error.set(true);
        } else {
            Auth.authenticatingState.set(true);
            Auth.error.set(false);
            return Accounts.callLoginMethod({
                methodArguments: [{username, pass: password, ldap: true}],
                validateResult(result) {
                },
                userCallback(result) {
                    Auth.authenticatingState.set(false);
                    //console.log JSON.stringify(result)
                    if (result && result.error) {
                        return Auth.error.set(true);
                    }
                }
            });
        }
    }
}

Authorization.initClass();

export var Auth = new Authorization();

// !Important Concept:
// Under the hood, each helper starts a new Tracker.autorun.
// When its reactive dependencies change, the helper is rerun.
// Helpers depend on their data context, passed arguments and other reactive data sources accessed during execution.
// eg. Meteor.user() is a reactive data source!
// See http://docs.meteor.com/#/full/template_helpers
Template.registerHelper("authError", Auth.authError);
Template.registerHelper("authorized", Auth.authorized);
Template.registerHelper("unauthorized", Auth.unauthorized);
Template.registerHelper("authReady", Auth.ready);
Template.registerHelper("authenticating", Auth.authenticating);

Template.ldapLogin2.events = {
    'click button[name="login2"]'(e, tpl) {
        return initLogin2(e, tpl);
    },

    'keyup input'(e, tpl) {
        if (e.keyCode === 13) { //If Enter Key Pressed
            return initLogin2(e, tpl);
        }
    }
};

// Initiate Login Process:
var initLogin2 = function (e, tpl) {
    const username = $(tpl.find('input[name="ldap"]')).val().trim();
    const password = $(tpl.find('input[name="password"]')).val().trim();
    return Auth.loginWithLdap2(username, password);
};


Template.login.onRendered(function () {
    const template = this;
    // See https://meteor.hackpad.com/Blaze-Proposals-for-v0.2-hsd54WPJmDV  and https://meteorhacks.com/kadira-blaze-hooks
    return template.autorun(function () {
// Watching the path change makes this autorun whenever the path changes!
// See http://docs.meteor.com/#/full/template_helpers
        FlowRouter.watchPathChange();
        return Tracker.afterFlush(function () {
            console.log("path changed to " + FlowRouter.current());
        });
    });
});

function __guard__(value, transform) {
    return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}