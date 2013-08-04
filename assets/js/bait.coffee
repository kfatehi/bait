window.Bait =
  # Wrap our usage of event source:
  # Incoming data is always an Array, the 
  # first value indicates the scope
  # the second value is the callback
  subscribe: (handlers) ->
    source = new EventSource('/events')
    source.addEventListener "message", (e) ->
      data = JSON.parse(e.data)
      handler = handlers[data[0]][data[1]]
      handler.apply(@, data.slice(2))

  GuiHelpers:
    # Click log to expand/collapse
    enable_expander: (el) ->
      el.on "click", (e) ->
        if el.css("max-height") is "100px"
          el.css "max-height", "100%"
        else
          el.css "max-height", "100px"
