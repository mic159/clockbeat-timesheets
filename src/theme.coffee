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
            @cache.push (0 for day in [0..7])
            
        @clear()
    
    clear: ->
        @$total.text ''
        for day in @$days
            $(day).text ''
        
        for task in @$tasks
            $(task).text ''
        
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
        
        numOrNothing = (num) -> if num > 0 then Math.round(num*100)/100 else ''
        @$total.text numOrNothing @total
        @changeWeek Math.round(@total)
        $(@$days[day]).text numOrNothing @dayTotals[day]
        $(@$tasks[task]).text numOrNothing @taskTotals[task]
        
########################
#   STYLER HELPER
########################

styler =
    start: ->
        if $('input[name="login_user"]').length > 0
            @loginPage()
        else
            @normalPage()
    
    load: (template, locals) ->
        $("body, head, style").empty()
        html = templates[template](locals)
        body = $("body")
        if body.length == 0
            $("html").append $("body")
        
        $("body").html html
        $("body").attr onload:""
        $("table, form, a").css display:"block"
    
    loginPage: ->
        @load 'templates/logon.jade'
        $("input[name=login_user]").focus()
    
    normalPage: ->
        @scraper = makeScraper $, $("body")
        @scraper.start()
        
        @scraper.selectOptions = templates["templates/options.jade"](options:@scraper.options)
        @scraper.templates = templates
        
        # Not dodgy at all...
        a = $("<a>Prettified by David Johnstone, Stephen Moore and Michael Cooper</a>")
        	.attr
        		href:"https://chrome.google.com/webstore/detail/njmnbiecjddpmnpekdghdmfcjojngagd"
        		target:"blank"
        @scraper.copyright += "<br/>" + a[0].outerHTML
        
        @load 'templates/base.jade', @scraper
        
        @timesheet = $(".timesheet")
        @setupFilter @scraper.options
        @setupCounter()
        @fillInTimeSheet()
        @setupCommentButton()
        
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
    
    setupFilter: (options) ->
        # Add behaviour to the textbox.
        scraper = @scraper
        activityOptions = undefined
        
        $("select").change ->
            el = $(this)
            if el.val().length > 0
                el.removeClass 'error'
            else
            
                if Number($('.task.total span', el.parent().parent()).text()) > 0
                    el.addClass 'error'
                
                
        allSelectOptions = templates["templates/options.jade"]({options})
        $('.filter-text').keyup ->                
            el = $(this)
            
            # Determine the select element to edit
            # And the current option
            grandparent = el.parent().parent()
            select = $('select:first', grandparent).first()
            current = select.val()
            
            filter = el.val()
            if filter.match /^\s*$/
                # No filter, put in all the available options
                select.html allSelectOptions
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
                select.html templates["templates/options.jade"]({options:replacement, bottomBlank:true})

########################
#   BEGIN!
########################

# I can't seem to work out how to remove things from the body before they load
# So we need to replace the functions defined by popupcalendarsub that are called
window.location = """
    javascript: function checkLogo(){}; function buildPage(){}; function biggercomment(){};
"""

window.onload = ->
document.onclick = ->
styler.start()
