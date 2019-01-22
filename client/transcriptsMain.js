import './transcriptsMain.html';

/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

Template.registerHelper('addKeys', all =>
    _.map(all, (i, k) => ({key: k, value: i}))
);

Template.transcriptsMain.onRendered(function () {
    const template = this;
    return Tracker.afterFlush(function () {
        console.log(`triggering Jquery mobile component creation for ${template.view.name}`);
        return $('body').trigger("create");
    });
});
