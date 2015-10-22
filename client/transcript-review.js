// Write your package code here!
Template.body.helpers({
  transcripts: function () {
      return Transcript.documents.find( {reviewComplete: false}, {sort: {createdAt: -1}});
  }
});
