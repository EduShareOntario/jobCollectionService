/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import {Template} from 'meteor/templating';
import {Session} from 'meteor/session';
import {Tracker} from 'meteor/tracker';

import {TranscriptIndex} from '../lib/transcriptIndex';

import './searchFilters.html';

Template.searchFilters.events({
    'change select'(e) {
        console.log(e);
        const newFilter = $(e.target).val();
        const dict = TranscriptIndex.getComponentDict();
        dict.set('currentPage', 1);
        return Session.set('searchFilter', newFilter);
    }
});

// Reactively triggered upon Session 'searchFilter' change.
// Updates reactive TranscriptIndex to trigger a new search.
// Should NOT depend on any reactive TranscriptIndex or related state, otherwise it
// will be triggered inappropriately!
Template.searchFilters.filter = function () {
    const searchFilter = Session.get('searchFilter');
    // Make sure the DOM exists before trying to update it!
    Tracker.afterFlush(function () {
        $('select.searchFilters').val(searchFilter); // doesn't trigger selection change!
        // keep the span label synchronized with the current selection!
        return $('span.searchFilters').text($('select.searchFilters option:selected').text());
    });
    const searchOptions = {
        props: {
            filter: searchFilter
        },
        skip: 0
    };
    // The Input component will trigger a search ONLY when the enter key is pressed.
    // Let's make sure the latest term is used upon filtering!
    const currentText = $('#search-input').val();
    const dict = TranscriptIndex.getComponentDict();
    dict.set('stopPublication', true);
    dict.set('searchOptions', searchOptions);
    return dict.set('searchDefinition', currentText);
};

Template.searchFilters.onCreated(function () {
    console.log("Template.searchFilters.onCreated called");
    //Make sure the searchFilter is initialized
    const searchFilter = (Session.get('searchFilter')) || 'pendingReview';
    Session.set('searchFilter', searchFilter);

    // Setup automatic filtering
    return Tracker.autorun(Template.searchFilters.filter);
});

