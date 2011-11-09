(function() {
  var activityOptions, calendarButton, choicesLink, copyLink, date, helpLink, inputTd, logoffLink, match, nextLink, optionsLink, prevLink, printLink, randomForm, submitButton, title;
  if ($('input[name="login_user"]').length > 0) {
    $("table").css({
      display: "block"
    });
    return;
  }
  $('form select').parent().parent().prepend('<td><input class="filter-text" type="text"/></td>');
  $('form tr:eq(0)').prepend('<td></td>');
  $('form tr:eq(1)').prepend('<td>Filter</td>');
  $('form tr:last').prepend('<td></td>');
  activityOptions = void 0;
  $('.filter-text').keyup(function() {
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
  $('style').html('');
  $('hr').remove();
  $('table').removeAttr('cellpadding').removeAttr('bgcolor');
  $('form table').attr('id', 'table').wrap('<div id="mainarea"></div>');
  $('#table td').removeAttr('width');
  inputTd = $('input[name="submitu"]').parent();
  $('input[name="submitu"]').remove();
  submitButton = $('<input id="submit-button" type="button" name="submitu" value="Update" onclick="updated()return true">');
  submitButton.click(function() {
    return $('form[name=theform]').submit();
  });
  $('#mainarea').append(submitButton);
  $('table:last td').removeAttr('style');
  $('#mainarea').append($('table:last').attr('id', 'weeks').attr('cellspacing', 0).attr('cellpadding', 0));
  $('#weeks .greytxt').html('<span class="nolink child">' + $('#weeks .greytxt').text() + '</span>');
  $('#weeks a').addClass('child');
  $('#weeks .child').each(function() {
    var match, text;
    text = $(this).text().replace('.00', '').replace('-', '0');
    match = /(\d+).(\w+).([\d\.]+)/.exec(text);
    text = "" + match[1] + " " + match[2] + " (" + match[3] + ")";
    return $(this).text(text);
  });
  $('p:last').remove();
  title = $('.title:first');
  match = /(.+) - Week commencing (.+)/.exec(title.text());
  date = match[2].replace('Jan', 'January').replace('Feb', 'February').replace('Mar', 'March').replace('Apr', 'April').replace('Jun', 'June').replace('Jul', 'July').replace('Aug', 'August').replace('Sep', 'September').replace('Oct', 'October').replace('Nov', 'November').replace('Dec', 'December');
  $('#mainarea').prepend("<h1>Timesheet for " + match[1] + "</h1><h2>" + date + "</h2>");
  title.remove();
  choicesLink = $('table:eq(2) a:eq(2)');
  optionsLink = $('.notonprint');
  calendarButton = $('input[type=image]');
  helpLink = $('a[target=helpwin]');
  prevLink = $('table:eq(3) a:eq(0)');
  nextLink = $('table:eq(3) a:eq(1)');
  copyLink = $('table:eq(3) a:eq(2)');
  printLink = $('table:eq(3) a:eq(3)');
  logoffLink = $("<a>Logoff</a>").attr({
    href: "/auth.php/logoff.php"
  });
  choicesLink.text(choicesLink.text().replace('(', '').replace(')', '').replace('choices', 'activities'));
  prevLink.text('Last week');
  nextLink.text('Next week');
  $('#mainarea').append('<div id="options" class="links"></div>');
  $('#options').append(optionsLink).append(helpLink).append(printLink).append(logoffLink);
  $('h2').after('<div id="navigation" class="links"></div>');
  $('#navigation').append(prevLink).append(calendarButton).append(nextLink);
  $('#table tr:last td:eq(1)').append(choicesLink).append(copyLink).wrapInner('<span class="links"></span>');
  $('table:eq(2)').remove();
  $('table:eq(2)').remove();
  randomForm = $('<form action="timeworked.php"></form>');
  $('body').prepend(randomForm);
  $("table").css({
    display: "block"
  });
}).call(this);
