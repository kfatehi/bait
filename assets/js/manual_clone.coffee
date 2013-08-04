window.ManualClone =
  init: ->
    form = $('.manual_clone')
    field = form.find('input')
    button = form.find('button')
    manual_clone = ->
      input = field.val()
      if input.length > 0
        if not button.attr('disabled')
          button.attr('disabled', 'disabled')
          $.post '/build/create', {clone_url: input}, (response) ->
            console.log response
            button.removeAttr('disabled')
      else
        alert "Enter a local path or remote url to a git repo, e.g.:\n
        Local: /Users/your/project\n
        Remote: https://github.com/your/project"

    field.keypress (e) ->
      if e.keyCode is 13
        manual_clone()

    button.on 'click', ->
      manual_clone()
