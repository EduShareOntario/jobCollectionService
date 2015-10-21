// Write your package code here!
Template.body.helpers({
  transcripts: function () {
      return Transcript.documents.find({checked: {$ne: true}}, {sort: {createdAt: -1}});
  }
});
