Template.searchFilters.events
  'change select': (e)->
    console.log e
    newFilter = $(e.target).val()
    Session.set 'searchFilter', newFilter

# Reactively triggered upon Session 'searchFilter' change.
# Updates reactive TranscriptIndex to trigger a new search.
# Should NOT depend on any reactive TranscriptIndex or related state, otherwise it
# will be triggered inappropriately!
Template.searchFilters.filter = () ->
  searchFilter = Session.get 'searchFilter'
  $('select.searchFilters').val searchFilter # doesn't trigger selection change!
  # keep the span label synchronized with the current selection!
  $('span.searchFilters').text $('select.searchFilters option:selected').text()
  TranscriptIndex.getComponentMethods().addProps 'filter', searchFilter
  # The Input component will trigger a search ONLY when the enter key is pressed.
  # Let's make sure the latest term is used upon filtering!
  currentText = $('#search-input').val()
  TranscriptIndex.getComponentDict().set 'searchDefinition', currentText
  #todo: reset paging

Template.searchFilters.onCreated () ->
  #Make sure the searchFilter is initialized
  searchFilter = (Session.get 'searchFilter') or 'pendingReview'
  Session.set 'searchFilter', searchFilter

  Deps.afterFlush () ->
    # Setup automatic filtering
    Deps.autorun Template.searchFilters.filter
