########################
#   STYLER HELPER
########################

styler =
    start: ->
        @common()
        
        if $('input[name="login_user"]').length > 0
            # It would seem this is a login page
            @loginPage()
        else
            # Any other page
            @normalPage()
        
        # Finally, show the main table
        # jQuery complains when I use .show or .fadeIn :(
        $("table", @mainArea).css display:"block"
        
    common: ->
        # Remove current CSS and ugly hrs
        $('hr').remove()
        $('style').html ''

        # Modify main table.
        $('table').removeAttr('cellpadding').removeAttr('bgcolor')
        
        $('form table').attr(id:'table').wrap $("<div/>").attr id:"mainarea"
        
        @mainArea = $ "#mainarea"
        @mainTable = $ "#table"
        @mainForm = @mainArea.parent()
        $("td", @mainTable).removeAttr('width').removeAttr('style')

        # Remove the "suggestion" footer
        $('p:last').remove()
        
        # Make clockbeat javascript be quiet
        for id in ["lblToday", "caption"]
            $('body').append $("<div/>").hide().attr {id}
    
    loginPage: ->
        $('table[id!="table"]').hide()
        button = @replaceSubmitButton text:"Login", selector:'input[name="submit"]'
        button.click =>
            @mainForm.submit()
        
        # Add the button and a header
        @mainArea
            .prepend($("<h1/>").text "TimeSheet Logon")
            .append(button)
        
        # Remove the random empty trs
        $("tr:eq(2), tr:eq(3)", @mainForm).remove()
        
        # Extend the length of those inputs
        $("input[type=text], input[type=password]", @mainForm).css width:"90%"
        
        # Remove random empty help td for login field
        $("tr:eq(0) .help:first", @mainForm).remove()
        
        # Move forgottenPassword link
        forgottenPassword = $("a:last").text "Forgot your password?"
        $("tr:eq(1)", @mainForm).append $("<td/>").addClass("help").append forgottenPassword
    
    normalPage: ->
        @setupFilter()
        
        # Create submit button
        button = @replaceSubmitButton text:"Update", selector:'input[name="submitu"]'
        button.click =>
            updated()
            @mainForm.submit()
        
        # Create weeks table
        weeks = @createWeeks()
        
        # Wrap button and weeks so I can line them up nicely
        weeks.wrap $("<div/>").addClass("portion").css width:"90%"
        button.wrap $("<div/>").addClass("portion").css width:"10%"
        
        # Add submit button and weeks 
        @utilities = $("<div/>").addClass "utilities"       
        @mainArea.append @utilities.append(button.parent()).append(weeks.parent())
        
        # Add Top Area stuff
        @addTopAreaStuff()
        
        # Action on the body element that fails if the main form isn't second
        randomForm = $ '<form action="timeworked.php"></form>'
        $('body').prepend(randomForm)
        
    replaceSubmitButton: ({selector, text}={}) ->
        selector ?= 'input[name="submitu"]'
        
        # Get the button to replace and the current text it shows
        replacing = $(selector)
        text ?= replacing.text()
        
        # Remove the one we're replacing
        replacing.remove()
        
        # Create a new submit button
        button = $("<input/>").attr
            id:"submit-button"
            type:"submit"
            name:"submitu"
            value:text
        
        # return replacement
        button
    
    addTopAreaStuff: ->
        # Move the title
        title = $('.title:first')
        match = /(.+) - Week commencing (.+)/.exec title.text()
        date = match[2].replace /(J(?:an|u(?:n|l))|Feb|Mar|Apr|Aug|Sep|Oct|Nov|Dec)/, (m) ->
            switch m
                when 'Jan' then 'January'
                when 'Feb' then 'February'
                when 'Mar' then 'March'
                when 'Apr' then 'April'
                when 'Jun' then 'June'
                when 'Jul' then 'July'
                when 'Aug' then 'August'
                when 'Sep' then 'September'
                when 'Oct' then 'October'
                when 'Nov' then 'November'
                when 'Dec' then 'December'
                else m
            
        @mainArea.prepend("<h1>Timesheet for #{match[1]}</h1><h2>#{date}</h2>")
        title.remove()

        # Get the various links at the top of the page which we want to move
        links = 
            choices: 'table:eq(2) a:eq(2)'
            options: '.notonprint'
            calendar: 'input[type=image]'
            help: 'a[target=helpwin]'
            prev: 'table:eq(3) a:eq(0)'
            next: 'table:eq(3) a:eq(1)'
            copy: 'table:eq(3) a:eq(2)'
            print: 'table:eq(3) a:eq(3)'
            logoff: "<a>Logoff</a>"
        
        for own name, selector of links
            links[name] = $ selector
        
        links.prev.text 'Last week'
        links.next.text 'Next week'
        links.logoff.attr href:"/auth.php/logoff.php"
        links.choices.text links.choices.text().replace('(','').replace(')','').replace('choices', 'activities')
        
        # Options area
        options = $("<div/>").attr id:"options", class:"links"
        for item in ['options', 'help', 'print', 'logoff']
            options.append links[item]
        
        # Navigation area
        navigation = $("<div/>").attr id:"navigation", class:"links"
        for item in ['prev', 'calendar', 'next']
            navigation.append links[item]
        
        # Put options and navigation into the dom
        $("h2").after navigation
        @mainArea.append options

        # Put the activities links in the table
        $('#table tr:last td:eq(1)').append(links.choices).append(links.copy).wrapInner($("<span/>").addClass "links")
    
    createWeeks: ->
        weeks = $('table:last').detach().attr
            id:'weeks'
            cellspacing:0
            cellpadding:0
        
        # Replace the greytext
        greytext = $(".greytxt", weeks)
        href = greytext.attr 'href'
        greytext.replaceWith $("<a/>").attr({href}).addClass("nolink child").text(greytext.text())
        
        # Change what each week displays
        $('a', weeks).addClass('child')
        $('td.oktxt', weeks).addClass('child').css fontSize:"" 
        $('.child', weeks).each ->
            el = $(this)
            text = el.text().replace('.00', '').replace('-', '0')
            match = /(\d+).(\w+).([\d\.]+)/.exec text
            text = "#{match[1]} #{match[2]} (#{match[3]})"
            el.text(text)
        
        # Finally, return
        weeks
    
    setupFilter: ->
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

########################
#   BEGIN!
########################

styler.start()
