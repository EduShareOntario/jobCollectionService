import './transcriptsMain.html';

/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

Template.registerHelper('addKeys', all =>
    _.map(all, (i, k) => ({key: k, value: i}))
);
