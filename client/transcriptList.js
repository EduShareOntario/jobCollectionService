/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import {Meteor} from 'meteor/meteor';
import {Session} from 'meteor/session';

import {Transcript} from '../lib/transcript';
import {TranscriptIndex} from '../lib/transcriptIndex';

import './transcriptList.html';

Template.transcriptList.onCreated(function () {
    console.log(`transcriptList created, userId is ${Meteor.userId()}`);
    const self = this;
    this.autorun(function () {
        if (Auth.authorized()) {
            const userId = Meteor.userId();
            console.log(`searchValue is ${Session.get('searchValue')}`);
            console.log(`TranscriptIndex is ${TranscriptIndex}`);
            const subscription = Meteor.subscribe("transcriptSearch", userId, Session.get("searchValue", {
                onReady() {
                    console.log(`transcriptList autorun subscribed to 'transcripts' publication. when userId is ${userId}`);
                    // See https://meteor.hackpad.com/Blaze-Proposals-for-v0.2-hsd54WPJmDV  and https://meteorhacks.com/kadira-blaze-hooks
                    return Tracker.afterFlush(function () {
                        console.log(`transcriptList autorun afterFlush following subscribe ready, DOM should exist. when userId is ${userId}`);
                        return $('[data-role="page"]').trigger("create");
                    });
                }
            }));
            if (subscription.ready()) {
                console.log("subscription ready!");
                $('[data-role="page"]').trigger("create");
            }
            return console.log(`subscribed to 'transcripts' publication when userId is ${userId}`);
        }
    });

    return self.transcripts = function () {
        console.log("template transcripts() called.");
        //return transcripts()
        return transcriptSearchResult();
    };
});

const transcripts = function () {
    console.log("transcripts() called");
    const cursor = Transcript.documents.find({
        reviewCompletedOn: undefined,
        applicant: {$ne: null}
    }, {sort: {ocasRequestId: 1}});
    cursor.observe({
        added(item) {
            return Tracker.afterFlush(() => $('[data-role="collapsible-set"]').enhanceWithin());
        }
    });
    return cursor;
};

var transcriptSearchResult = function () {
    if (Session.get("searchValue")) {
        return Transcript.documents.find({}, {sort: [["score", "desc"]]});
    } else {
        return Transcript.documents.find({});
    }
};

Template.transcriptList.helpers({
    transcripts() {
        console.log("transcripts() helper called");
        //    return Template.instance().transcripts()
        return transcriptSearchResult();
    },

//todo: move/refactor into transcript search page
    transcriptSearchResult() {
        return transcriptSearchResult();
    }
});

Template.transcriptList.events({
    'click .view-transcript'(e, t) {
    },
//    Meteor.call "startReview", this._id
    "keyup input"() {
        console.log("hello keyup");
        return console.log(this.target);
    },
    "keypress input"() {
        console.log("hello keypress");
        return console.log(this.target);
    }
});

Template.transcriptList.onRendered(function () {
    const template = this;
    //
    // The following code realizes the recipe documented at http://stackoverflow.com/questions/25486954/meteor-rendered-callback-and-applying-jquery-plugins.
    // In our case we need to initialize jQuery Mobile elements!
    //
    // Based on article explanation:
    // As a quick recap, this is what is happening with this code under the hood :
    //   - Template.transcriptList.rendered is called but the #each block has not yet rendered the transcriptSummary items.
    //   - Our reactive computation is setup and we listen to updates from the 'transcripts' collection (just like the #each block is doing in its own distinct computation).
    //   - Some time later, the 'transcripts' collection is updated and both the #each block computation as well as our custom computation are invalidated - because they depend
    //     on the SAME cursor - and thus will rerun.
    //     Now the tricky part is that we can't tell which computation is going to rerun first, it could be one or the other, in an nondeterministic way.
    //     This is why we need to run the plugin initialization in a Tracker.afterFlush callback.
    //   - The #each block logic is executed and items get inserted in the DOM.
    //   - The flush cycle (rerunning every invalidated computations) is done and our Tracker.afterFlush callback is thus executed.
    //
    //   This pattern allows us to reinitialize our jQuery plugins (carousels, masonry-like stuff, etc...) whenever new items are being added to the model and subsequently rendered in the DOM by Blaze.
    //
    return template.autorun(function () {
// reference a reactive dependency such that this 'autorun' computation will get called whenever it changes!
        const t = transcripts();
        // afterFlush so the DOM is ready!
        return Tracker.afterFlush(() => $('[data-role="collapsible-set"]').enhanceWithin());
    });
});


Template.transcriptSummary.helpers({
    academicRecords() {
// Reactively populate
        let recs = this.pescCollegeTranscript.CollegeTranscript.Student.AcademicRecord;
        if (recs !== Array) {
            recs = [recs];
        }
        return recs;
    },

    pathForTranscriptReview() {
        const path = FlowRouter.path("transcriptReviewDetail", {transcriptId: this.myId()});
        return path;
    },

    reviewIconClass() {
        let iconClass;
        if (this.reviewCompletedOn) {
            iconClass = 'review-complete';
        } else if (this.outbound) {
            iconClass = 'ui-icon-action';
        } else {
            iconClass = 'ui-icon-arrow-d';
        }
        return iconClass;
    }
});