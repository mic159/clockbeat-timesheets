makeScraper = (window, $) ->
    start: (get) ->
        unless get?
            # No get specified, determine all the possible keys
            get = []
            for key, func of this
                if key.startsWith 'get_'
                    get.push key.slice 4
        
        # Execute everything that needs to be gathered
        for part in get
            func = this["get_#{part}"]
            if _.isFunction func
                func.call this, part
          
    ########################
    #   TITLE
    ########################
    
    get_title: ->
        original = $(".title:first").text()
        @title = @extractTitle original
    
    extractTitle: (original) ->
        match = /(.+) - Week commencing (.+)/.exec original
        
        # Extract name and date from the original title
        name = match[1]
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
          
        {original, name, date}
          
    ########################
    #   ACTIVITIES/ENTRIES
    ########################
    
    get_activities: ->
        # Seems that nodejs thinks the desired script tag is second last
        # But browser says the actual last one....
        code = $("script:last")
        if code.html().length is 0
            scripts = $("script")
            code = $(scripts[scripts.length-2])
        
        javascript = code.html().replace /, ddproj/g, ', ""'

        info = eval """
          (function() {
              biggercomment=function(){}; 
              #{javascript};
              return {ddproj:ddproj, ddboxes:ddboxes, myproj:myproj}
          })()
        """

        {@activities, @entries} = @extractActivities info
    
    extractActivities: (info) ->
        entries = []
        activities = {}

        for [key, name] in info.ddproj
          if key isnt ""
              activities[key] = name

        for [a, b, key] in info.ddboxes
          if key isnt ""
              entries.push key

        {activities, entries}
          
    ########################
    #   DAYS
    ########################
    
    get_days: ->
        daysRow = $("form[name=theform] tr:eq(0)")
        @days = for day in $("td.weekday, td.weekend", daysRow)
            txt = $(day).text()
            if txt.length is 0 then continue
            txt
          
    ########################
    #   INTERESTING LINKS
    ########################
    
    get_links: ->
        selectors = 
            choices: 'table:eq(2) a:eq(2)'
            options: '.notonprint'
            calendar: 'input[type=image]'
            help: 'a[target=helpwin]'
            prev: 'table:eq(3) a:eq(0)'
            next: 'table:eq(3) a:eq(1)'
            copy: 'table:eq(3) a:eq(2)'
            print: 'table:eq(3) a:eq(3)'
        
        @links = links =
            logoff: {href:"/auth.php/logoff.php", text:"Log off"}
            
        for own name, selector of selectors
            next = $ selector
            links[name] = {href:next.attr("href"), text:next.text()}
        
        links.prev.text = "Last Week"
        links.next.text = "Next Week"
        links
          
    ########################
    #   WEEKS
    ########################
    
    get_weeks: ->
          
########################
#   EXPORT
########################

exports ?= window
exports.makeScraper = makeScraper
