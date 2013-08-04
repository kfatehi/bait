# Iterate through each build
each_build = (cb) ->
  $.each $(".build"), (i,e) ->
    cb $(e)

init_build = (build) ->
  # Color the output logs
  pre = build.find(".output pre")
  output = pre.html()
  if output? && output.size > 0
    pre.html ansi2html(output)
  
  # Enable expansion toggle
  Bait.GuiHelpers.enable_expander pre  

  build.find('a.remove').click ->
    $.ajax
      type: "DELETE"
      url: $(@).data('url')

  build.find('a.retest').click ->
    $(@).parents('.build').find('pre').html("")
    $.post $(@).data('url')

Zepto ($) ->
  ManualClone.init()

  #Build.fetch_all (builds) ->
  #  init_build build

  # Initialize all the builds
  each_build (build) -> init_build build

  # Define event handlers
  Bait.subscribe
    global:
      new_build: (data) ->
        html = Build.to_html(data.build)
        if $('.build').length > 0
          $('.build').first().before html
        else
          $('ul#builds').append html
        init_build $("##{data.build.id}")
    build:
      output: (id, text) ->
        pre = $("##{id}").find('pre')
        pre.append ansi2html(text)
      status: (id, text) ->
        header = $("##{id}").find(".header")
        header.find(".status").html text
        header.attr "class", "header #{text}"
      remove: (id) ->
        $("##{id}").remove()
