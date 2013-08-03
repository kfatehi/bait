each_build = (cb) ->
  builds = $(".build")
  $.each builds, (i, e) ->
    cb $(e)

enable_expander = (el) ->
  el.on "click", (e) ->
    if el.css("max-height") is "100px"
      el.css "max-height", "100%"
    else
      el.css "max-height", "100px"

L = (og) ->
  console.log og
Zepto ($) ->
  each_build ((build) ->
    
    # Color the output logs
    pre = build.find(".output pre")
    pre.html ansi2html(pre.html())
    
    # Enable expansion toggle
    enable_expander pre
    
    # Listen for events
    source = new EventSource("/build/" + build.attr("id") + "/events")
    source.addEventListener "message", (e) ->
      data = JSON.parse(e.data)
      switch data.category
        when "output"
          pre.append data.output
        when "status"
          header = build.find(".header")
          header.find(".status_icon").html data.status
          header.attr "class", "header " + data.status
        else
          console.log "nothing"

  ), false

