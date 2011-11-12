########################
#   COUNTER HELPER
########################

class Counter
    constructor: (@$total, @$days, @$tasks) ->
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
    
    update: (task, day, value) ->
        old = @cache[task][day]
        @total -= old
        @dayTotals[day] -= old
        @taskTotals[task] -= old
        
        @cache[task][day] = value
        @total += value
        @dayTotals[day] += value
        @taskTotals[task] += value
        
        @$total.text @total
        $(@$days[day]).text @dayTotals[day]
        $(@$tasks[task]).text @taskTotals[task]
        
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
        $("body").html html
        $("body").attr onload:""
        $("table, form, a").css display:"block"
    
    loginPage: ->
        @load 'templates/logon.jade'
        $("input[name=login_user]").focus()
    
    normalPage: ->
        @scraper = makeScraper window, $
        @scraper.start()
        @scraper.templates = templates
        
        @load 'templates/base.jade', @scraper
        
        @timesheet = $(".timesheet")
        @setupFilter()
        @setupCounter()
        @fillInTimeSheet()
        @setupCommentButton()
        
        $(".timesheet").fadeIn()
    
    setupCounter: ->
        @counterTotal = $("td.all.total span", @timesheet)
        @counterDays = $("td.day.total span", @timesheet)
        @counterTasks = $("td.task.total span", @timesheet)
        @counter = new Counter @counterTotal, @counterDays, @counterTasks
    
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
    
    setupCommentButton: ->
        $("button.makecomment", @timesheet).click ->
            comment = $(this).parent().parent().next()
            if comment.is(":visible")
                if $("input", comment).val().length is 0
                    comment.hide()
            else
                comment.show()
            
            false
    
    setupFilter: ->
        # Add behaviour to the textbox.
        scraper = @scraper
        activityOptions = undefined
                
        $("select").mousedown ->
            el = $(this)
            if $("option.blank", el).length is 0
                el.append $("<option/>").addClass "blank"
            
        $('.filter-text').keyup ->
            if not activityOptions?
                activityOptions = $ "<select/>"
                for key, value of scraper.activities
                    activityOptions.append $("<option>#{value}</option>").attr value:key
                
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
                        if option.text().toLowerCase().indexOf(term) < 0 and option.attr("value").length > 0
                            option.remove()
                            break

########################
#   BEGIN!
########################

styler.start()
