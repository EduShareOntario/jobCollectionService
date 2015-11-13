Template.transcriptsMainLayout.rendered = () ->
  Deps.afterFlush () ->
    $('[data-role="page"]').trigger("create")
