Meteor.subscribe('transcripts', {
  onReady: function () {
    console.log("onReady And the Items actually Arrive", arguments);
  },
  onStop: function () {
    console.log("onError", arguments);
  }
});
