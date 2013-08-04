window.Build =
  to_html: (build) ->
    """
    <li id="#{build.id}" class="build">
      <div class="header #{build.status}">
        <div class="status">#{build.status}</div>
        <a href="#{build.clone_url}">#{build.name}</a>
        <div class="ref">#{build.ref?=''}</div>
      </div>
      <div class="output">
        <pre>#{build.output}</pre>
      </div>
      <div class="actions">
        <a href="#" data-url="/build/#{build.id}">Remove</a>
        |
        <a href="#" data-url="/build/#{build.id}/retest">Retest</a>
      </div>
    </li>
    """
