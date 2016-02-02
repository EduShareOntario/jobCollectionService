Template.transcriptSearch.helpers
  transcriptIndex: ->
    #console.log TranscriptIndex.config
    TranscriptIndex # Instance of EasySearch.Index

  inputAttributes: ->
    {
      placeholder: "Search...",
      'data-role': "none",
      'id': "search-input"
    }

Template.transcriptSearchNav.helpers
  loadMoreAttributes: ->
    {
      class: "load-more-button btn ui-btn ui-shadow ui-corner-all",
      'data-role': "none"
    }
