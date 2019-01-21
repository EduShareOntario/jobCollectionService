/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import {Template} from 'meteor/templating';
import {ReactiveVar} from 'meteor/reactive-var';
import {Meteor} from 'meteor/meteor';
import {HTTP} from 'meteor/http';

import './transcriptDetail.html';

Template.transcriptDetail.onCreated(function () {
    const template = this;
    template.transcriptHtml = new ReactiveVar();
    return template.autorun(function () {
        const transcriptId = FlowRouter.getParam('transcriptId');
        return template.subscribe("transcript", transcriptId, {
            onReady() {
// Convert XML to HTML using the transcript document service
                const t = getTranscript(transcriptId);
                if (t.pescCollegeTranscriptXML) {
                    const startReviewNeeded = t.awaitingReview();
                    console.log(`startReviewNeeded:${startReviewNeeded}`);
                    if (startReviewNeeded) {
                        Meteor.call("startReview", t._id);
                    }
                    return HTTP.post(Meteor.settings.public.transcriptToHtmlURL, {
                            headers: {"Content-Type": "application/x-www-form-urlencoded"},
                            params: {"doc": t.pescCollegeTranscriptXML}
                        }, (error, response) =>
// Update the reactive state to trigger the view to generate!
                            template.transcriptHtml.set(response.content)
                    );
                } else {
                    return template.transcriptHtml.set(`<h2>Transcript ${transcriptId} not found</h2>`);
                }
            }
        });
    });
});

var getTranscript = function (id) {
    if (!id) {
        id = getTranscriptId();
    }
    return Transcript.documents.findOne(id) || {};
};

var getTranscriptId = () => FlowRouter.getParam('transcriptId');

Template.transcriptDetail.helpers({
    transcript() {
        return getTranscript();
    },

    transcriptId() {
        return getTranscriptId();
    },

    transcriptHtml() {
        return Template.instance().transcriptHtml.get();
    },

    showHtml() {
        if (Template.instance().transcriptHtml.get()) {
            return true;
        }
    },

    showXml() {
        return true;
    },

    showJson() {
        return true;
    }
});

Template.transcriptDetail.events = {
    'click .review-complete'(e) {
//console.log "User completed review of transcript: #{this._id}"
        Meteor.call("completeReview", this._id);
        return FlowRouter.go("transcriptReviewList");
    },

    'click .review-takeover'(e) {
//console.log "User review takeover for transcript: #{this._id}"
        return Meteor.call("startReview", this._id);
    },

    'click .cancel-review'(e) {
//console.log "User cancelled review of transcript: #{this._id}"
        Meteor.call("cancelReview", this._id);
        return FlowRouter.go("transcriptReviewList");
    }
};
