Template.searchFilters.events
  'change select': (e)->
    console.log e
    newFilter = $(e.target).val()
    dict = TranscriptIndex.getComponentDict()
    dict.set 'currentPage', 1
    Session.set 'searchFilter', newFilter

# Reactively triggered upon Session 'searchFilter' change.
# Updates reactive TranscriptIndex to trigger a new search.
# Should NOT depend on any reactive TranscriptIndex or related state, otherwise it
# will be triggered inappropriately!
Template.searchFilters.filter = () ->
  searchFilter = Session.get 'searchFilter'
  # Make sure the DOM exists before trying to update it!
  Deps.afterFlush () ->
    $('select.searchFilters').val searchFilter # doesn't trigger selection change!
    # keep the span label synchronized with the current selection!
    $('span.searchFilters').text $('select.searchFilters option:selected').text()
  searchOptions = {
    props:
      filter:
        searchFilter
    skip: 0
  }
  # The Input component will trigger a search ONLY when the enter key is pressed.
  # Let's make sure the latest term is used upon filtering!
  currentText = $('#search-input').val()
  dict = TranscriptIndex.getComponentDict()
  dict.set 'stopPublication', true
  dict.set 'searchOptions', searchOptions
  dict.set 'searchDefinition', currentText

Template.searchFilters.onCreated () ->
  console.log "Template.searchFilters.onCreated called"
  #Make sure the searchFilter is initialized
  searchFilter = (Session.get 'searchFilter') or 'pendingReview'
  Session.set 'searchFilter', searchFilter

  # Setup automatic filtering
  Deps.autorun Template.searchFilters.filter

