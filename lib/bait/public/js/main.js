function each_log(cb)
{
  var logs = $('.build .output pre');
  $.each(logs, function(i,e) {cb(e)});
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
  each_log(function(pre) {
    // Color them
    pre.innerHTML=ansi2html(pre.innerHTML);
    // Enable expansion toggle
    enable_expander($(pre));
    // Listen for events
    window.source = new EventSource('/events');
    source.addEventListener('message', function(e) {
      console.log(e);
    });
  }, false);
})

