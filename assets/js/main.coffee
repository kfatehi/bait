Zepto ($) ->
  ManualClone.init()

  Build.all (builds) ->
    $.each builds, (i,d) ->
      Build.List.add d.build

  Bait.subscribe
    global:
      new_build: (data) ->
        Build.List.add data.build
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
