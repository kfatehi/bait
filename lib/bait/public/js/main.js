function each_build(cb)
{
  var builds = $('.build');
  $.each(builds, function(i,e) {
    cb($(e))
  });
}

function enable_expander(el)
{
  el.on('click', function(e) {
    if (el.css('max-height') === '100px')
      el.css('max-height', '100%')
    else
      el.css('max-height', '100px')
  })
}

function L(og){console.log(og)}
Zepto(function($){
  each_build(function(build) {
    // Color the output logs
    var pre = build.find('.output pre');
    pre.html(ansi2html(pre.html()));
    // Enable expansion toggle
    enable_expander(pre);
    // Listen for events
    source = new EventSource('/build/'+build.attr('id')+'/events');
    source.addEventListener('message', function(e) {
      var data = JSON.parse(e.data);
      switch (data.category) {
        case 'output':
          pre.append(data.output);
          break;
        case 'status':
          var header = build.find('.header');
          header.find('.status_icon').html(data.status);
          header.attr('class', 'header '+data.status);
          break;
        default:
          console.log('nothing');
      }
    });
  }, false);
})

