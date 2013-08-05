

/** bait.coffee **/

(function() {
  window.Bait = {
    subscribe: function(handlers) {
      var source;
      source = new EventSource('/events');
      return source.addEventListener("message", function(e) {
        var data, handler;
        data = JSON.parse(e.data);
        handler = handlers[data[0]][data[1]];
        return handler.apply(this, data.slice(2));
      });
    }
  };

}).call(this);


/** build.coffee **/

(function() {
  window.Build = {
    find: function(id) {
      return $("#" + id);
    },
    all: function(cb) {
      return $.getJSON('/build', function(data) {
        return cb(data);
      });
    },
    DOM: {
      UIHelper: {
        expand_toggle: function(el) {
          return el.on("click", function(e) {
            if (el.css("max-height") === "100px") {
              return el.css("max-height", "100%");
            } else {
              return el.css("max-height", "100px");
            }
          });
        },
        enable_links: function(element) {
          element.find('a.remove').click(function() {
            $.ajax({
              type: "DELETE",
              url: $(this).data('url')
            });
            return false;
          });
          return element.find('a.retest').click(function() {
            $(this).parents('.build').find('pre').html("");
            $.post($(this).data('url'));
            return false;
          });
        }
      },
      init: function(build_id) {
        var build, output, pre;
        build = Build.find(build_id);
        pre = build.find(".output pre");
        output = pre.html();
        if ((output != null) && output.size > 0) {
          pre.html(ansi2html(output));
        }
        Build.DOM.UIHelper.expand_toggle(pre);
        return Build.DOM.UIHelper.enable_links(build);
      }
    },
    List: {
      add: function(build) {
        var html;
        html = Build.to_html(build);
        if ($('.build').length > 0) {
          $('.build').first().before(html);
        } else {
          $('ul#builds').append(html);
        }
        return Build.DOM.init(build.id);
      }
    },
    SimpleCov: {
      url: function(id) {
        return "/build/" + id + "/coverage/index.html";
      },
      text: function(truthy) {
        if (truthy) {
          return "Coverage";
        } else {
          return "";
        }
      }
    },
    to_html: function(build) {
      return "<li id=\"" + build.id + "\" class=\"build\">\n  <div class=\"header " + build.status + "\">\n    <div class=\"status\">" + build.status + "</div>\n    <a href=\"" + build.clone_url + "\">" + build.name + "</a>\n    <div class=\"ref\">" + (build.ref != null ? build.ref : build.ref = '') + "</div>\n    <a href=\"" + (Build.SimpleCov.url(build.id)) + "\"\n       class=\"simplecov\">\n         " + (Build.SimpleCov.text(build.simplecov)) + "</a>\n  </div>\n  <div class=\"output\">\n    <pre>" + build.output + "</pre>\n  </div>\n  <div class=\"actions\">\n    <a href=\"#\" class=\"remove\" data-url=\"/build/" + build.id + "\">Remove</a>\n    |\n    <a href=\"#\" class=\"retest\" data-url=\"/build/" + build.id + "/retest\">Retest</a>\n  </div>\n</li>";
    }
  };

}).call(this);


/** main.coffee **/

(function() {
  Zepto(function($) {
    ManualClone.init();
    Build.all(function(builds) {
      $.each(builds, function(i, d) {
        return Build.List.add(d.build);
      });
      return $("#loading").remove();
    });
    return Bait.subscribe({
      global: {
        new_build: function(data) {
          return Build.List.add(data.build);
        }
      },
      build: {
        output: function(id, text) {
          var pre;
          pre = Build.find(id).find('pre');
          return pre.append(ansi2html(text));
        },
        status: function(id, text) {
          var header;
          header = Build.find(id).find(".header");
          header.find(".status").html(text);
          return header.attr("class", "header " + text);
        },
        remove: function(id) {
          return Build.find(id).remove();
        },
        simplecov: function(id, supported) {
          var link;
          link = Build.find(id).find('.simplecov');
          link.attr('href', Build.SimpleCov.url(id));
          return link.text(Build.SimpleCov.text(supported));
        }
      }
    });
  });

}).call(this);


/** manual_clone.coffee **/

(function() {
  window.ManualClone = {
    init: function() {
      var button, field, form, manual_clone;
      form = $('.manual_clone');
      field = form.find('input');
      button = form.find('button');
      manual_clone = function() {
        var input;
        input = field.val();
        if (input.length > 0) {
          if (!button.attr('disabled')) {
            button.attr('disabled', 'disabled');
            return $.post('/build/create', {
              clone_url: input
            }, function(response) {
              field.val('');
              return button.removeAttr('disabled');
            });
          }
        } else {
          return alert("Enter a local path or remote url to a git repo, e.g.:\n        Local: /Users/your/project\n        Remote: https://github.com/your/project");
        }
      };
      field.keypress(function(e) {
        if (e.keyCode === 13) {
          return manual_clone();
        }
      });
      return button.on('click', function() {
        return manual_clone();
      });
    }
  };

}).call(this);
