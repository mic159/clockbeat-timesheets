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
        $(".timesheet").fadeIn()
        
        @timesheet = $(".timesheet")
        
        @setupFilter()
        @setupCommentButton()
    
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
