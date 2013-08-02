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
    window.source = new EventSource('/build/'+build.attr('id')+'/events');
    source.addEventListener('message', function(e) {
      var data = JSON.parse(e.data);
      console.log(data);
      if (data.id && data.running && data.running[1] == false) {
        console.log('ok');
        var pre = $('#'+data.id).find('.output pre');
        pre.html(ansi2html(data.output));
      }
    });
  }, false);
})

