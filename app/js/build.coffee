window.Build =
  find: (id) -> $("##{id}")

  all: (cb) -> $.getJSON '/build', (data) -> cb(data)

  DOM:
    UIHelper:
      # Click log to expand/collapse
      expand_toggle: (el) ->
        el.on "click", (e) ->
          if el.css("max-height") is "100px"
            el.css "max-height", "100%"
          else
            el.css "max-height", "100px"

      enable_links: (element) ->
        element.find('a.remove').click ->
          $.ajax
            type: "DELETE"
            url: $(@).data('url')
          return false

        element.find('a.retest').click ->
          $(@).parents('.build').find('pre').html("")
          $.post $(@).data('url')
          return false

    init: (build_id) ->
      build = Build.find(build_id)

      # Color the output logs
      pre = build.find(".output pre")
      output = pre.html()
      if output? && output.size > 0
        pre.html ansi2html(output)
      
      # Enable expansion toggle
      Build.DOM.UIHelper.expand_toggle pre  
      Build.DOM.UIHelper.enable_links build

  List:
    add: (build) ->
      html = Build.to_html(build)
      if $('.build').length > 0
        $('.build').first().before html
      else
        $('ul#builds').append html
      Build.DOM.init build.id

  SimpleCov:
    url: (id) ->
      "/build/#{id}/coverage/index.html"
    text: (truthy) ->
      if truthy then "Coverage" else ""

  to_html: (build) ->
    """
    <li id="#{build.id}" class="build">
      <div class="header #{build.status}">
        <div class="status">#{build.status}</div>
        <a href="#{build.clone_url}">#{build.name}</a>
        <div class="ref">#{build.ref?=''}</div>
        <a href="#{Build.SimpleCov.url(build.id)}"
           class="simplecov">
             #{Build.SimpleCov.text(build.simplecov)}</a>
      </div>
      <div class="output">
        <pre>#{build.output}</pre>
      </div>
      <div class="actions">
        <a href="#" class="remove" data-url="/build/#{build.id}">Remove</a>
        |
        <a href="#" class="retest" data-url="/build/#{build.id}/retest">Retest</a>
      </div>
    </li>
    """
