function each_log(cb)
{
  var logs = $('.build .output pre');
  $.each(logs, function(i,e) {cb(e)});
}

function expand_log_toggle(id)
{
  $('#'+id).find('pre').css('max-height', '100%');
}

function L(og){console.log(og)}
Zepto(function($){
  each_log(function(pre) {
    // Color them
    pre.innerHTML=ansi2html(pre.innerHTML);
    // Enable expansion toggle
    $(pre).on('click', function(e) {
      if ($(pre).css('max-height') === '100px')
        $(pre).css('max-height', '100%')
      else
        $(pre).css('max-height', '100px')
    });
  });
})

