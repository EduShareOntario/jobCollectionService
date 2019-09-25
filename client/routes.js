/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
*/
import {Auth} from "./login";
import {Meteor} from 'meteor/meteor';
import {Session} from 'meteor/session';
import {Accounts} from 'meteor/accounts-base';
import {Tracker} from 'meteor/tracker';

BlazeLayout.setRoot('#page');

const exposed = FlowRouter.group({});
exposed.route('/login', {
    name: 'login',
    action() {
        if (!Session.get('redirectAfterLogin')) {
// default to /review when original path is /login
            Session.set('redirectAfterLogin', '/review');
        }
        return BlazeLayout.render("login");
    }
});
exposed.route('/unauthorized', {
    name: 'unauthorized',
    action() {
        return BlazeLayout.render("transcriptsMain", {content: "unauthorized"});
    }
});
exposed.route('/logout', {
    name: 'logout',
    action() {
        Session.set('redirectAfterLogin', null);
        Meteor.logoutOtherClients();
        Meteor.logout();
        return FlowRouter.redirect('/login');
    }
});

// Before going to any route that is part of this route group, make sure the user is logged in!
const ensureLoggedIn = function (context, redirect, stop) {
    console.log("ensureLoggedIn called");
    const currentRouteName = FlowRouter.getRouteName();

    if (currentRouteName !== 'login') {
// remember where they want to go!
        const currentPath = FlowRouter.current().path;
        Session.set('redirectAfterLogin', currentPath);
        if (!Auth.ready() && !Auth.authenticating()) {
            console.log("ensureLoggedIn redirecting to /login");
            return redirect('/login');
        }
    }
};

const privateRoutes = FlowRouter.group({
    name: 'private',
    triggersEnter: [ensureLoggedIn]
});

//Force evaluation of route when user object changes.
Tracker.autorun(function () {
    const userId = Meteor.userId();
    const currentRouteName = FlowRouter.getRouteName();
    const redirectRoutePath = Session.get('redirectAfterLogin');
    return console.log(`Current Route or session redirectAfterLogin changed: currentRouteName ${currentRouteName}, redirectAfterLogin is ${redirectRoutePath} and userId ${userId}`);
});

// After successful login, redirect the user to the route they originally tried.
Accounts.onLogin(function () {
    const redirectRoutePath = Session.get('redirectAfterLogin');
    console.log(`Accounts onLogin with currentRoute ${FlowRouter.getRouteName()}, and redirectAfterLogin ${redirectRoutePath}`);
    Session.set('redirectAfterLogin', null);
    return FlowRouter.redirect(redirectRoutePath);
});

privateRoutes.route('/review', {
    name: 'transcriptReviewList',
    action() {
        console.log("Rendering transcript review list");
        return BlazeLayout.render("transcriptsMain", {content: "transcriptSearch"});
    }
});
privateRoutes.route('/review/:transcriptId', {
    name: 'transcriptReviewDetail',
    action(params) {
        console.log("Reviewing transcript:", params.transcriptId);
        return BlazeLayout.render("transcriptsMain", {content: "transcriptDetail"});
    }
});
privateRoutes.route('/search', {
    name: 'transcriptSearch',
    action() {
        console.log("Rendering transcript search");
        return BlazeLayout.render("transcriptsMain", {content: "transcriptSearch"});
    }
});
