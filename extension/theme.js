(function() {
  var styler;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty;
  styler = {
    start: function() {
      this.common();
      if ($('input[name="login_user"]').length > 0) {
        this.loginPage();
      } else {
        this.normalPage();
      }
      return $("table", this.mainArea).css({
        display: "block"
      });
    },
    common: function() {
      var id, _i, _len, _ref, _results;
      $('hr').remove();
      $('style').html('');
      $('table').removeAttr('cellpadding').removeAttr('bgcolor');
      $('form table').attr({
        id: 'table'
      }).wrap($("<div/>").attr({
        id: "mainarea"
      }));
      this.mainArea = $("#mainarea");
      this.mainTable = $("#table");
      this.mainForm = this.mainArea.parent();
      $("td", this.mainTable).removeAttr('width').removeAttr('style');
      $('p:last').remove();
      _ref = ["lblToday", "caption"];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        id = _ref[_i];
        _results.push($('body').append($("<div/>").hide().attr({
          id: id
        })));
      }
      return _results;
    },
    loginPage: function() {
      var button, forgottenPassword;
      $('table[id!="table"]').hide();
      button = this.replaceSubmitButton({
        text: "Login",
        selector: 'input[name="submit"]'
      });
      button.click(__bind(function() {
        return this.mainForm.submit();
      }, this));
      this.mainArea.prepend($("<h1/>").text("TimeSheet Logon")).append(button);
      $("tr:eq(2), tr:eq(3)", this.mainForm).remove();
      $("input[type=text], input[type=password]", this.mainForm).css({
        width: "90%"
      });
      $("tr:eq(0) .help:first", this.mainForm).remove();
      forgottenPassword = $("a:last").text("Forgot your password?");
      return $("tr:eq(1)", this.mainForm).append($("<td/>").addClass("help").append(forgottenPassword));
    },
    normalPage: function() {
      var button, randomForm, weeks;
      this.setupFilter();
      button = this.replaceSubmitButton({
        text: "Update",
        selector: 'input[name="submitu"]'
      });
      button.click(__bind(function() {
        updated();
        return this.mainForm.submit();
      }, this));
      weeks = this.createWeeks();
      weeks.wrap($("<div/>").addClass("portion").css({
        width: "90%"
      }));
      button.wrap($("<div/>").addClass("portion").css({
        width: "10%"
      }));
      this.utilities = $("<div/>").addClass("utilities");
      this.mainArea.append(this.utilities.append(button.parent()).append(weeks.parent()));
      this.addTopAreaStuff();
      randomForm = $('<form action="timeworked.php"></form>');
      return $('body').prepend(randomForm);
    },
    replaceSubmitButton: function(_arg) {
      var button, replacing, selector, text, _ref;
      _ref = _arg != null ? _arg : {}, selector = _ref.selector, text = _ref.text;
            if (selector != null) {
        selector;
      } else {
        selector = 'input[name="submitu"]';
      };
      replacing = $(selector);
            if (text != null) {
        text;
      } else {
        text = replacing.text();
      };
      replacing.remove();
      button = $("<input/>").attr({
        id: "submit-button",
        type: "submit",
        name: "submitu",
        value: text
      });
      return button;
    },
    addTopAreaStuff: function() {
      var date, item, links, match, name, navigation, options, selector, title, _i, _j, _len, _len2, _ref, _ref2;
      title = $('.title:first');
      match = /(.+) - Week commencing (.+)/.exec(title.text());
      date = match[2].replace('Jan', 'January').replace('Feb', 'February').replace('Mar', 'March').replace('Apr', 'April').replace('Jun', 'June').replace('Jul', 'July').replace('Aug', 'August').replace('Sep', 'September').replace('Oct', 'October').replace('Nov', 'November').replace('Dec', 'December');
      this.mainArea.prepend("<h1>Timesheet for " + match[1] + "</h1><h2>" + date + "</h2>");
      title.remove();
      links = {
        choices: 'table:eq(2) a:eq(2)',
        options: '.notonprint',
        calendar: 'input[type=image]',
        help: 'a[target=helpwin]',
        prev: 'table:eq(3) a:eq(0)',
        next: 'table:eq(3) a:eq(1)',
        copy: 'table:eq(3) a:eq(2)',
        print: 'table:eq(3) a:eq(3)',
        logoff: "<a>Logoff</a>"
      };
      for (name in links) {
        if (!__hasProp.call(links, name)) continue;
        selector = links[name];
        links[name] = $(selector);
      }
      links.prev.text('Last week');
      links.next.text('Next week');
      links.logoff.attr({
        href: "/auth.php/logoff.php"
      });
      links.choices.text(links.choices.text().replace('(', '').replace(')', '').replace('choices', 'activities'));
      options = $("<div/>").attr({
        id: "options",
        "class": "links"
      });
      _ref = ['options', 'help', 'print', 'logoff'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        options.append(links[item]);
      }
      navigation = $("<div/>").attr({
        id: "navigation",
        "class": "links"
      });
      _ref2 = ['prev', 'calendar', 'next'];
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        item = _ref2[_j];
        navigation.append(links[item]);
      }
      $("h2").after(navigation);
      this.mainArea.append(options);
      return $('#table tr:last td:eq(1)').append(links.choices).append(links.copy).wrapInner($("<span/>").addClass("links"));
    },
    createWeeks: function() {
      var greytext, href, weeks;
      weeks = $('table:last').detach().attr({
        id: 'weeks',
        cellspacing: 0,
        cellpadding: 0
      });
      greytext = $(".greytxt", weeks);
      href = greytext.attr('href');
      greytext.replaceWith($("<a/>").attr({
        href: href
      }).addClass("nolink child").text(greytext.text()));
      $('a', weeks).addClass('child');
      $('td.oktxt', weeks).addClass('child').css({
        fontSize: ""
      });
      $('.child', weeks).each(function() {
        var el, match, text;
        el = $(this);
        text = el.text().replace('.00', '').replace('-', '0');
        match = /(\d+).(\w+).([\d\.]+)/.exec(text);
        text = "" + match[1] + " " + match[2] + " (" + match[3] + ")";
        return el.text(text);
      });
      return weeks;
    },
    setupFilter: function() {
      var activityOptions;
      $('form select').parent().parent().prepend('<td><input class="filter-text" type="text"/></td>');
      $('form tr:eq(0)').prepend('<td></td>');
      $('form tr:eq(1)').prepend('<td>Filter</td>');
      $('form tr:last').prepend('<td></td>');
      activityOptions = void 0;
      return $('.filter-text').keyup(function() {
        var current, el, grandparent, option, options, select, term, terms, _i, _len, _results;
        if (!(activityOptions != null)) {
          activityOptions = $("<option/>");
          activityOptions.append($('select:first').children().clone());
        }
        el = $(this);
        grandparent = el.parent().parent();
        select = $('select:first', grandparent).first();
        current = select.val();
        select.children().remove();
        select.append(activityOptions.children().clone());
        select.val(current);
        options = select.children();
        terms = el.val().toLowerCase().split(/\W/).filter(function(n) {
          return n !== '';
        });
        if (terms.length > 0) {
          _results = [];
          for (_i = 0, _len = options.length; _i < _len; _i++) {
            option = options[_i];
            option = $(option);
            _results.push((function() {
              var _j, _len2, _results2;
              _results2 = [];
              for (_j = 0, _len2 = terms.length; _j < _len2; _j++) {
                term = terms[_j];
                if (option.text().toLowerCase().indexOf(term) < 0) {
                  option.remove();
                  break;
                }
              }
              return _results2;
            })());
          }
          return _results;
        }
      });
    }
  };
  styler.start();
}).call(this);
