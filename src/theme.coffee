########################
#   COUNTER HELPER
########################

class Counter
    constructor: (@$total, @$days, @$tasks, @$week) ->
        @total = 0
        @dayTotals = (0 for day in [0..7])
        @taskTotals = (0 for task in @$tasks)
        
        @cache = []
        for task in @taskTotals
            @addRow()
            
        @clear()
    
    addRow: (row) ->
        @cache.push (0 for day in [0..7])
        
    nextIndex: ->
        @taskTotals.length
    
    numOrNothing: ($el, num=0) ->
        $($el)[0].innerHTML = if num > 0 then Math.round(num*100)/100 else '&nbsp;'
        
    clear: ->
        @numOrNothing @$total
        for day in @$days
            @numOrNothing day
        
        for task in @$tasks
            @numOrNothing task
        
    changeWeek: (value) ->
        v = @$week.text()
        v = v.replace /\(\d+\)/, "(#{value})"
        @$week.text v
            
    setupInput: (input, select, num, place) ->
        counter = this
        $(input).change ->
            el = $(this)
            val = el.val()
                
            number = Number val
            unless isNaN(number)
                el.removeClass 'error'
                number = Math.round(number*100)/100
                if number > 0
                    el.val number
                else
                    el.val ''
                counter.update num, place, number
            else
                el.addClass 'error'
            
            if val.length > 0 and (isNaN(number) or number > 0)
                if select.val().length is 0
                    select.addClass 'error'
            else
                if counter.taskTotals[num] == 0
                    select.removeClass 'error'
    
    update: (task, day, value) ->
        old = @cache[task][day]
        @total -= old
        @dayTotals[day] -= old
        @taskTotals[task] -= old
        
        @cache[task][day] = value
        @total += value
        @dayTotals[day] += value
        @taskTotals[task] += value
        
        numOrNothing = (num) -> 
        @numOrNothing @$total, @total
        @changeWeek Math.round(@total)
        @numOrNothing @$days[day], @dayTotals[day]
        @numOrNothing @$tasks[task], @taskTotals[task]
        
########################
#   STYLER HELPER
########################

styler =
    base: ""
    node: false
    
    setupOnPop: ->
        # Find popstate events so we can change the page when back/forward buttons are pressed
        $(window).bind "popstate", => @goTo "#{window.location.pathname}#{window.location.search}"
        
    start: (@$body) ->
        if $('input[name="login_user"]', @$body).length > 0
            @loginPage()
        else
            @normalPage()
            
    goTo: (location, cb) ->
        if not @changing
            $(".container").fadeOut =>
                @showLoading()
            @changing = true
            
        @currentLocation = location
        $.get "#{@base}#{location}", (data) =>
            if location == @currentLocation
                @start @bodyFromText data
                @changing = false
                cb?()
    
    load: (template, locals) ->
        body = $("body")
        
        # Detect if the page was left faded in.
        if $(".container:first", body).is(":visible")
            fade = false
        else
            fade = true
        
        if body.length is 0
            body = $("<body/>")
            $("html").append body
        else
            body.empty()

        html = partial template, locals
        body.html html
        $("table").css display:"table"
        $("form, a").css display:"block"
        
        if @afterAjax and fade
            $(".container", body).hide()
            $(".container", body).fadeIn()
        else
            @afterAjax = true
        
            
        @$body = $("body")
        $(".loading").remove()
    
    addTitle: (txt) ->
        head = $("head")
        if head.length is 0
            head = $("<head/>")
            $("html").append head
        
        title = $("title", head)
        if title.length is 0
            title = $("<title/>")
            head.append title
        
        if not txt?
            info = @scraper.title
            txt = "Timesheet for #{info.name} - #{info.date}"
        title.text txt
      
    fixCss: (type) ->
        if not @node
            $("body").css background:"none"
            
        if type == "normal"
            if @node
                $("body").css height:"0", padding:0
                $(".container").css margin: "10px auto"
                $(".timesheet").css margin: "10px auto"
            else
                $("body").css height:0, padding:10
        else
            $("body").css height:"100%"
    
    loginPage: ->
        scraper = makeScraper($, @$body)
        scraper.get_copyright()
        @load 'logon', scraper
        @fixCss 'login'
        @setupSubmitButton @$body
        @addTitle "Timesheet Logon"
        $("input[name=login_user]", @$body).focus()
    
    normalPage: ->
        if window.location.pathname == "/auth.php/logoff.php"
            window.history.pushState {}, "", "/auth.php/timeworked.php"
            
        @scraper = makeScraper $, @$body
        @scraper.start()
        
        @scraper.selectOptions = partial 'options', options:@scraper.options
        @scraper.partial = partial
        
        @load 'base', @scraper
        @fixCss "normal"
        
        @timesheet = $(".timesheet")
        
        @addTitle()
        @setupFilter()
        @setupCounter()
        @fillInTimeSheet()
        @setupAjaxyButtons()
        @setupSubmitButton @timesheet
        @setupCommentButton()
        @setupNewRowButton()
        
        $(".timesheet").show()
    
    setupCounter: ->
        @counterTotal = $("td.all.total span", @timesheet)
        @counterDays = $("td.day.total span", @timesheet)
        @counterTasks = $("td.task.total span", @timesheet)
        @counterWeek = $(".weeks .nolink", @timesheet)
        @counter = new Counter @counterTotal, @counterDays, @counterTasks, @counterWeek
    
    fillInTimeSheet: ->
        for entry, index in @scraper.entries
            $("select:eq(#{index})", @timesheet).val entry
        
        for values, num in @scraper.values[0...index]
            tr = $("tr.values:eq(#{num})", @timesheet)
            
            comment = values[0]
            if comment.length > 0
                commentTr = tr.next()
                $("input", commentTr).val comment
                commentTr.show()
            
            for day, place in $(".day", tr)
                value = values[place+1]
                if value.length > 0
                    @counter.update num, place, Number(value)
                    $(day).val value
        
        counter = @counter
        for tr, num in $("tr.values", @timesheet)
            select = $("select", tr)
            for input, place in $(".day", tr)
                @counter.setupInput input, select, num, place
        
        return
    
    setupCommentButton: ->
        $("button.makecomment", @timesheet).click ->
            comment = $(this).parent().parent().next()
            if comment.is(":visible")
                if $("input", comment).val().length is 0
                    comment.hide()
            else
                comment.show()
            
            false
    
    setupSubmitButton: ($context) ->
        styler = this
        $("input[type=submit]", $context).click ->
            submit = $(this)
            form = submit.closest 'form'
            data = form.serialize()
            
            if submit.val() is "Update"
                $("form.main input").attr "disabled", "disable"
                $("form.main button").attr "disabled", "disable"
                $("form.main select").attr "disabled", "disable"
                $("#submit").val "Updating..."
            else
                $(".container").fadeOut =>
                    styler.showLoading()
            
            $.post "#{styler.base}#{form.attr 'action'}", data, (data, status, e) ->
                styler.start styler.bodyFromText data
            false
    
    setupAjaxyButtons: ->
        styler = this
        $("a.ajaxy", @$body).click ->
            href = $(this).attr "href"
            title = styler.scraper.title
            title = "Timesheet for #{title.name} - #{title.date}"
            
            # Register change in location and go to it
            history.pushState {}, title, href
            styler.goTo href
            
            # Return false to prevent the click action making the page reload
            false
    
    setupNewRowButton: ->
        $("button.newrow", @timesheet).click =>
            # Create new row
            index = @counter.nextIndex()
            selectOptions = @scraper.selectOptions
            $row = $ partial 'row', {selectOptions, index, days:@scraper.days}
            
            # Setup filter
            @setupFilter
                $select : $("select", $row)
                $filter : $(".filter-text", $row)
            
            # Insert new row
            $("tr.totals", @timesheet).before $row
            
            # Tell counter about the new row
            select = $("select", $row)
            @counter.addRow()
            for input, place in $(".day", $row)
                @counter.setupInput input, select, index, place
            
            # Add hidden stuff
            $hidden = $("div.hidden", @timesheet)
            $hidden.append partial 'hidden', {index, days:@scraper.days}
            
            # Adjust linecount
            $lineCount = $("input[name='linecount']", $hidden)
            newLineCount = Number($lineCount.val()) + 1
            $lineCount.val newLineCount
            
            # Prevent default click action
            false
                
    bodyFromText: (data) ->
        index = data.indexOf "<body"
        data = "<html>#{data[index..data.length-1]}"
            .replace(/onload="[^"]+"/g, "")
            .replace(/<(\/?)(script|img)/g, '<$1pre class="was_$2"')
            
        newBody = $ "<body/>"
        for item in $ data
            newBody.append item
        
        # Make it apparent where the activities are
        $(".was_script:last", newBody).addClass("activities_javascript")
        
        # Re put in the version information
        versionAt = data.lastIndexOf("Version")
        version = data[versionAt...data.indexOf("<", versionAt)]
        newBody.append $("<p/>").text version
        
        # Return the new body
        newBody
    
    showLoading: ->
        loading = $(".loading")
        if loading.length is 0
            $("body").append $("<span>Loading...</span>").addClass "loading"
        else
            loading.show()
    
    setupFilter: ({$select, $filter}={}) ->
        # Add behaviour to the textbox.
        $select ?= $("select")
        $filter ?= $(".filter-text")
        {options, selectOptions} = @scraper
        
        $select.change ->
            el = $(this)
            if el.val().length > 0
                el.removeClass 'error'
            else
            
                if Number($('.task.total span', el.parent().parent()).text()) > 0
                    el.addClass 'error'
                
        $filter.keyup ->                
            el = $(this)
            
            # Determine the select element to edit
            # And the current option
            grandparent = el.parent().parent()
            select = $('select:first', grandparent).first()
            current = select.val()
            
            filter = el.val()
            if filter.match /^\s*$/
                # No filter, put in all the available options
                select.html selectOptions
                select.val current
            else
                # Create a regex from the filter
                terms = filter.toLowerCase().split(/\W/).filter (n) -> n!= ''
                regex = new RegExp "^.*#{terms.join '.*'}.*$", 'i'
                
                # Find all the options that apply to the filter
                replacement = []
                for info in options
                    if info[0].match regex
                        replacement.push info
                
                # Create and add the necessary options
                select.html partial 'options', {options:replacement, bottomBlank:true}
            
            haveHours = Number($("task.total span", grandparent).text()) > 0
            haveChoice = select.val().length > 0
            # xor!
            if not haveHours isnt not haveChoice
                select.removeClass 'error'
            else
                select.addClass 'error'

########################
#   EXPORTS
########################

exports ?= window
exports.styler = styler
exports.Counter = Counter
