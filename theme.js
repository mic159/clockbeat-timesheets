/*var e = document.createElement('script');
e.src = 'http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js';
e.type='text/javascript';
document.getElementsByTagName('head')[0].appendChild(e);

function waitForJQuery() {
    if (window.$) {
        $(document).ready(stuff);
    } else {
        setTimeout(waitForJQuery, 100);
    }
}

setTimeout(waitForJQuery, 100);*/
stuff();

function stuff() {

// Duplicate the activity selection lists (this needs to be done if filtering is done, as you can't just hide something in a list).
$('select.colx, select.col').each(function() {
    $(this).parent().append($(this).clone().removeClass().addClass('backup').attr('disabled', 'disabled').hide());
});

// Create the filter textbox.
$('form select.colx, form select.col').parent().parent().prepend('<td><input class="filter-text" type="text"/></td>');

// Fix the table
$('form tr:eq(0)').prepend('<td></td>');
$('form tr:eq(1)').prepend('<td>Filter</td>');
$('form tr:last').prepend('<td></td>');

// Add behaviour to the textbox.
$('.filter-text').keyup(function() {
    var select = $(this).parent().parent().find('select.colx:first, select.col:first').first();
    var terms = $(this).val().toLowerCase().split(/\W/).filter(function(n) { return n != ''; });
    var current = select.val();
    // Regenerate the list with all items.
    select.children().remove();
    select.append(select.parent().find('.backup').children().clone());
    select.val(current);
    var options = select.find('.col');
    // Remove the first (and empty) element when text is being filtered on.
    if (terms.length > 0) {
        select.find('.colx').remove();
        // Remove all items that don't match the filter.
        for (var i = 0; i < options.length; i++) {
            var option = $(options[i]);
            for (var j = 0; j < terms.length; j++) {
                if (option.text().toLowerCase().indexOf(terms[j]) < 0) {
                    $(options[i]).remove();
                    break;
                }
            }
        }
    }
});

// Restyle

// Remove current CSS and attach my own.
$('style').html('');
// This can use either a big string of CSS or an external stylesheet. The random number is only there to force reloads when developing.
//$('style').html(css);
//$('head').append('<link href="http://localhost:8080/static/t.css?v=' + Math.round(Math.random()*100000) + '" rel="stylesheet" type="text/css" />');

// Remove ugly horizontal rules.
$('hr').remove();

// Modify main table.
$('table').removeAttr('cellpadding').removeAttr('bgcolor');
$('form table').attr('id', 'table').wrap('<div id="mainarea"></div>');
$('#table td').removeAttr('width');
var inputTd = $('input[name="submitu"]').parent();
$('input[name="submitu"]').remove();
$('#mainarea').append('<input id="submit-button" type="button" name="submitu" value="Update" onclick="updated();return true;">');
$('#submit-button').click(function() {
    $('form[name=theform]').submit();
});
$('table:last td').removeAttr('style');

// Move previous weeks table into main area and change the internals a bit.
$('#mainarea').append($('table:last').attr('id', 'weeks').attr('cellspacing', 0).attr('cellpadding', 0));
$('#weeks .greytxt').html('<span class="nolink child">' + $('#weeks .greytxt').text() + '</span>');
$('#weeks a').addClass('child');
$('#weeks .child').each(function() {
    var text = $(this).text().replace('.00', '').replace('-', '0');
    var match = /(\d+).(\w+).([\d\.]+)/.exec(text);
    text = match[1] + ' ' + match[2] + ' (' + match[3] + ')';
    $(this).text(text);
});

// Remove the "suggestion" footer
$('p:last').remove();

// Move the title
var title = $('.title:first');
var match = /(.+) - Week commencing (.+)/.exec(title.text());
var date = match[2].replace('Jan', 'January').replace('Feb', 'February').replace('Mar', 'March').replace('Apr', 'April').replace('Jun', 'June').replace('Jul', 'July').replace('Aug', 'August').replace('Sep', 'September').replace('Oct', 'October').replace('Nov', 'November').replace('Dec', 'December');
$('#mainarea').prepend('<h1>Timesheet for ' + match[1] + '</h1><h2>' + date + '</h2>');
title.remove();

// Get the various links at the top of the page which we want to move
var choicesLink = $('table:eq(2) a:eq(2)');
var optionsLink = $('.notonprint');
var calendarButton = $('input[type=image]');
var helpLink = $('a[target=helpwin]');
var prevLink = $('table:eq(3) a:eq(0)');
var nextLink = $('table:eq(3) a:eq(1)');
var copyLink = $('table:eq(3) a:eq(2)');
var printLink = $('table:eq(3) a:eq(3)');

choicesLink.text(choicesLink.text().replace('(','').replace(')','').replace('choices', 'activities'));
prevLink.text('Last week');
nextLink.text('Next week');

$('#mainarea').append('<div id="options" class="links"></div>');
$('#options').append(optionsLink).append(helpLink).append(printLink);

// Construct a navigation segment
$('h2').after('<div id="navigation" class="links"></div>');
$('#navigation').append(prevLink).append(calendarButton).append(nextLink);

// Put the activities links in the table
$('#table tr:last td:eq(1)').append(choicesLink).append(copyLink).wrapInner('<span class="links"></span>');

// Delete old stuff
$('table:eq(2)').remove();
$('table:eq(2)').remove();

}

var css = 'body{background:-moz-radial-gradient(#c9cedd,#c9cedd,#8e96ad) repeat scroll 0 0 transparent;background:-webkit-radial-gradient(#c9cedd,#c9cedd,#8e96ad) repeat scroll 0 0 transparent;font-family:"Lucida Grande","Lucida Sans Unicode",Helvetica,Arial,Verdana,sans-serif;font-size:13px;height:100%}a{color:#333;text-decoration:none}a:hover{text-decoration:underline;color:#999}td,p{font-size:13px}input,select{font-family:"Lucida Grande","Lucida Sans Unicode",Helvetica,Arial,Verdana,sans-serif;font-size:13px}select{padding-right:2px;width:420px}input,select{border:1px solid #ddd;border-radius:3px;padding:2px 4px}td.weekday input,td.weekend input{width:40px}select{padding-right:2px}#mainarea{background-color:#fbf7e9;background:-webkit-linear-gradient(#fbf7e9,#ebe3d4) repeat scroll 0 0 transparent;background:-moz-linear-gradient(#fbf7e9,#ebe3d4) repeat scroll 0 0 transparent;border:1px solid #82817b;border-radius:11px 11px 11px 11px;box-shadow:0 0 11px #898989;margin:70px auto 10px;padding:20px;width:1100px;position:relative}#table td{padding:3px}#table tr:nth-child(2){font-weight:bold}.filter-text{width:100px}input[type="button"]:hover{-webkit-transition-duration:.5s;-webkit-transition-property:background-color;-moz-transition-duration:.5s;-moz-transition-property:background-color;background-color:#ddd7c6}input[type="button"]{-webkit-transition-duration:.5s;-webkit-transition-property:background-color;-moz-transition-duration:.5s;-moz-transition-property:background-color;background-color:#f2eee1;border:1px solid #bbb;padding:5px 25px}#weeks{margin:20px auto 0;background-color:#f4f1e2;border:1px solid #bbb;border-radius:3px}#weeks .child{padding:4px 8px;background-color:#f4f1e2;-webkit-transition-duration:.5s;-webkit-transition-property:background-color;-moz-transition-duration:.5s;-moz-transition-property:background-color;font-size:11px;text-align:center;color:#333;display:block;text-decoration:none}#weeks td:first-child .child{border-top-left-radius:3px;border-bottom-left-radius:3px}#weeks td:last-child .child{border-top-right-radius:3px;border-bottom-right-radius:3px}#weeks a:hover{background-color:#ddd7c6;-webkit-transition-duration:.5s;-webkit-transition-property:background-color;-moz-transition-duration:.5s;-moz-transition-property:background-color}#weeks .nolink{color:#999}h1{font-size:17px;margin-top:0}h2{font-size:14px}#options{position:absolute;top:20px;right:30px}.links a,.links input{margin:0 12px}.links a:first-child{margin-left:0}.links a:last-child{margin-right:0}input[type=image]{vertical-align:middle;border:none;opacity:.3;-webkit-transition-duration:.5s;-webkit-transition-property:opacity;-moz-transition-duration:.5s;-moz-transition-property:opacity}input[type=image]:hover{vertical-align:middle;opacity:1;-webkit-transition-duration:.5s;-webkit-transition-property:opacity;-moz-transition-duration:.5s;-moz-transition-property:opacity}';
