Template.searchFilters.events
  'change select': (e)->
    console.log e
    selectElement = e.target
    $('span.searchFilters').text selectElement.options[selectElement.selectedIndex].label
    Session.set 'searchFilter', $(selectElement).val()
    TranscriptIndex.getComponentMethods().addProps 'searchFilter', Session.get 'searchFilter'
    # Get the latest search text input too
    latestSearchText = $('#search-input').val()
    TranscriptIndex.getComponentMethods().search(latestSearchText)

Template.searchFilters.onCreated () ->
  @autorun () ->
    Deps.afterFlush () ->
      currentSearchFilter = Session.get 'searchFilter'
      $('select.searchFilters').val currentSearchFilter if currentSearchFilter

      # keep the span label synchronized with the current selection!
      $('span.searchFilters').text $('select.searchFilters option:selected').text()
