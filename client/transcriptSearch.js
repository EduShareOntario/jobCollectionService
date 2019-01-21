/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import {TranscriptIndex} from '../lib/transcriptIndex';

import './transcriptSearch.html';
import './transcriptSearch.css';

Template.transcriptSearch.helpers({
    transcriptIndex() {
//console.log TranscriptIndex.config
        return TranscriptIndex;
    }, // Instance of EasySearch.Index

    inputAttributes() {
        return {
            placeholder: "Search...",
            'data-role': "none",
            'id': "search-input"
        };
    }
});

Template.transcriptSearchNav.helpers({
    loadMoreAttributes() {
        return {
            class: "load-more-button btn ui-btn ui-shadow ui-corner-all",
            'data-role': "none"
        };
    }
});

