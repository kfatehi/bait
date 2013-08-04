each_build = (cb) ->
  $.each $(".build"), (i,e) ->
    cb $(e)

enable_expander = (el) ->
  el.on "click", (e) ->
    if el.css("max-height") is "100px"
      el.css "max-height", "100%"
    else
      el.css "max-height", "100px"

Zepto ($) ->
  each_build (build) ->
    
    # Color the output logs
    pre = build.find(".output pre")
    pre.html ansi2html(pre.html())
    
    # Enable expansion toggle
    enable_expander pre
    
    # Each build may emit events
    source = new EventSource("/build/" + build.attr("id") + "/events")
    source.addEventListener "message", (e) ->
      data = JSON.parse(e.data)
      switch data.category
        when "output"
          pre.append data.output
        when "status"
          header = build.find(".header")
          header.find(".status").html data.status
          header.attr "class", "header " + data.status
        when "removal"
          build.remove()
