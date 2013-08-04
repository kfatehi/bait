# Iterate through each build
each_build = (cb) ->
  $.each $(".build"), (i,e) ->
    cb $(e)

# Click log to expand/collapse
enable_expander = (el) ->
  el.on "click", (e) ->
    if el.css("max-height") is "100px"
      el.css "max-height", "100%"
    else
      el.css "max-height", "100px"

# Wrap my use of event source:
# Incoming data is always an Array, the 
# first value of which indicates the handler
event_source = (url, handlers) ->
  source = new EventSource(url)
  source.addEventListener "message", (e) ->
    data = JSON.parse(e.data)
    handlers[data[0]](data)

init_build = (build) ->
  # Color the output logs
  pre = build.find(".output pre")
  pre.html ansi2html(pre.html())
  
  # Enable expansion toggle
  enable_expander pre
  
  # Build may emit their own events
  event_source "/build/#{build.attr('id')}/events",
    output: (args) ->
      pre.append args[1]
    status: (args) ->
      header = build.find(".header")
      header.find(".status").html args[1]
      header.attr "class", "header " + args[1]
    remove: ->
      build.remove()


Zepto ($) ->
  # Initialize all the builds
  each_build (build) -> init_build build

  # Handle global events
  event_source "/events",
    new_build: (data) ->
      $('.build').first().before(data.build)
      
