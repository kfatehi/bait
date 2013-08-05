Zepto ($) ->
  ManualClone.init()

  Build.all (builds) ->
    $.each builds, (i,d) ->
      Build.List.add d.build
    $("#loading").remove()

  Bait.subscribe
    global:
      new_build: (data) ->
        Build.List.add data.build
    build:
      output: (id, text) ->
        pre = Build.find(id).find('pre')
        pre.append ansi2html(text)
      status: (id, text) ->
        header = Build.find(id).find(".header")
        header.find(".status").html text
        header.attr "class", "header #{text}"
      remove: (id) ->
        Build.find(id).remove()
      simplecov: (id, supported) ->
        link = Build.find(id).find('.simplecov')
        link.attr 'href', Build.SimpleCov.url(id)
        link.text Build.SimpleCov.text(supported)
