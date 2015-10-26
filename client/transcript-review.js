// Write your package code here!
Template.body.helpers({
  transcripts: function () {
      return Transcript.documents.find( {reviewCompletedOn: undefined}, {sort: {createdAt: -1}});
  }
});
