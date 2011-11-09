## Create the filter textbox.
$('form select').parent().parent().prepend('<td><input class="filter-text" type="text"/></td>')

# Fix the table
$('form tr:eq(0)').prepend('<td></td>')
$('form tr:eq(1)').prepend('<td>Filter</td>')
$('form tr:last').prepend('<td></td>')

# Add behaviour to the textbox.
activityOptions = undefined
$('.filter-text').keyup ->
    if not activityOptions?
        activityOptions = $ "<option/>"
        activityOptions.append $('select:first').children().clone()
        
    el = $(this)
    grandparent = el.parent().parent()
    
    # Determine the select element to edit
    # And the current option
    select = $('select:first', grandparent).first()
    current = select.val()
    
    # Regenerate the list with all items.
    select.children().remove()
    select.append activityOptions.children().clone()
    
    # Reset selected option and get the options and terms
    select.val current
    options = select.children()
    terms = el.val().toLowerCase().split(/\W/).filter (n) -> n != ''
    
    # Remove all items that don't match the filter.
    if terms.length > 0
        for option in options
            option = $(option)
            for term in terms
                if option.text().toLowerCase().indexOf(term) < 0
                    option.remove()
                    break

# Restyle

# Remove current CSS and attach my own.
$('style').html('')

# Remove ugly horizontal rules.
$('hr').remove()

# Modify main table.
$('table').removeAttr('cellpadding').removeAttr('bgcolor')
$('form table').attr('id', 'table').wrap('<div id="mainarea"></div>')
$('#table td').removeAttr('width')

inputTd = $('input[name="submitu"]').parent()
$('input[name="submitu"]').remove()

submitButton = $('<input id="submit-button" type="button" name="submitu" value="Update" onclick="updated()return true">')
    .click ->
        $('form[name=theform]').submit()
    
$('#mainarea').append submitButton
$('table:last td').removeAttr('style')

# Move previous weeks table into main area and change the internals a bit.
$('#mainarea').append($('table:last').attr('id', 'weeks').attr('cellspacing', 0).attr('cellpadding', 0))
$('#weeks .greytxt').html('<span class="nolink child">' + $('#weeks .greytxt').text() + '</span>')
$('#weeks a').addClass('child')
$('#weeks .child').each ->
    text = $(this).text().replace('.00', '').replace('-', '0')
    match = /(\d+).(\w+).([\d\.]+)/.exec text
    text = "#{match[1]} #{match[2]} (#{match[3]})"
    $(this).text(text)

# Remove the "suggestion" footer
$('p:last').remove()

# Move the title
title = $('.title:first')
match = /(.+) - Week commencing (.+)/.exec title.text()
date = match[2]
    .replace('Jan', 'January')
    .replace('Feb', 'February')
    .replace('Mar', 'March')
    .replace('Apr', 'April')
    .replace('Jun', 'June')
    .replace('Jul', 'July')
    .replace('Aug', 'August')
    .replace('Sep', 'September')
    .replace('Oct', 'October')
    .replace('Nov', 'November')
    .replace('Dec', 'December')
    
$('#mainarea').prepend("<h1>Timesheet for #{match[1]}</h1><h2>#{date}</h2>")
title.remove()

# Get the various links at the top of the page which we want to move
choicesLink = $('table:eq(2) a:eq(2)')
optionsLink = $('.notonprint')
calendarButton = $('input[type=image]')
helpLink = $('a[target=helpwin]')
prevLink = $('table:eq(3) a:eq(0)')
nextLink = $('table:eq(3) a:eq(1)')
copyLink = $('table:eq(3) a:eq(2)')
printLink = $('table:eq(3) a:eq(3)')

choicesLink.text(choicesLink.text().replace('(','').replace(')','').replace('choices', 'activities'))
prevLink.text('Last week')
nextLink.text('Next week')

$('#mainarea').append('<div id="options" class="links"></div>')
$('#options').append(optionsLink).append(helpLink).append(printLink)

# Construct a navigation segment
$('h2').after('<div id="navigation" class="links"></div>')
$('#navigation').append(prevLink).append(calendarButton).append(nextLink)

# Put the activities links in the table
$('#table tr:last td:eq(1)').append(choicesLink).append(copyLink).wrapInner('<span class="links"></span>')

# Delete old stuff
$('table:eq(2)').remove()
$('table:eq(2)').remove()
# Action on the body element that fails if the main form isn't second
randomForm = $ '<form action="timeworked.php"></form>'
$('body').prepend(randomForm)

# Finally, show the main table
# jQuery complains when I use .show or .fadeIn :(
$("table").css display:"block"