Template.searchFilters.events
  'change select': (e)->
    console.log e
    Template.searchFilters.handleFilterChange($(e.target).val())

Template.searchFilters.performSearch = () ->
  searchFilter = Session.get 'searchFilter'
  # Do nothing if the searchFilter is undefined
  return unless searchFilter

  # The Input component will trigger a search when the enter key is pressed on the input, but
  # it doesn't update the session and we still need to initialize the search properties by calling addProps!
  currentText = $('#search-input').val()
  TranscriptIndex.getComponentMethods().addProps 'filter', searchFilter
  TranscriptIndex.getComponentMethods().search(currentText)

Template.searchFilters.handleFilterChange = (filter) ->
  # keep the span label synchronized with the current selection!
  $('span.searchFilters').text $('select.searchFilters option:selected').text()
  Session.set 'searchFilter', filter # should trigger autorun!

Template.searchFilters.onCreated () ->
  Deps.afterFlush () ->
    # Setup the autorun to keep the search results updating
    Deps.autorun Template.searchFilters.performSearch

Template.searchFilters.onRendered () ->
  Deps.afterFlush () ->
    searchFilter = (Session.get 'searchFilter') or 'pendingReview'
    $('select.searchFilters').val searchFilter # doesn't trigger selection change!
    # Simulate the filter change
    Template.searchFilters.handleFilterChange searchFilter
