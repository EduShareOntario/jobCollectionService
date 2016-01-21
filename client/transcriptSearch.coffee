Template.transcriptSearch.helpers
  transcriptIndex: ->
    console.log "transcriptIndex helper called!"
    console.log TranscriptIndex.config
    TranscriptIndex # Instance of EasySearch.Index

  inputAttributes: ->
    {
      placeholder: "Search...",
      'data-role': "none"
    }

Template.transcriptSearch.events =
  'keyup input#searchText' : (e) ->
    console.log "hello keyup"
    console.log e.target

  'keypress input' : (e) ->
    console.log "hello keypress"
    console.log e.target

  'click input' : (e) ->
    console.log "hello click"
    console.log e.target

  'click button[name="searchButton"]': (e) ->
    console.log "hello button" + e

  'click input[name="searchText"]': (e) ->
    console.log "hello input" + e

Template.transcriptSearchNav.helpers
  loadMoreAttributes: ->
    {
      class: "load-more-button btn ui-btn ui-shadow ui-corner-all",
      'data-role': "none"
    }
