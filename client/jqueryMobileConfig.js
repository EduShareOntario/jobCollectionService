$(document).bind("mobileinit", function () {
  // jQuery Mobile will automatically bind the clicks on anchor tags in your document.
  // Setting this option to false will prevent all anchor click handling including the addition of active button state and alternate link blurring.
  // This should only be used when attempting to delegate the click management to another library or custom code.
  $.mobile.linkBindingEnabled = false;
  // jQuery Mobile will automatically listen and handle changes to the location.hash.
  // Disabling this will prevent jQuery Mobile from handling hash changes, which allows you to handle them yourself or use simple deep-links within a document that scroll to a particular id.
  $.mobile.hashListeningEnabled = false;
});