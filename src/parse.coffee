makeScraper = ($, $body) ->
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
        original = $(".title:first", $body).text()
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
        code = $(".activities_javascript", $body)
        javascript = code.html().replace /, ddproj/g, ', ""'

        info = eval """
          (function() {
              biggercomment=function(){}; 
              #{javascript};
              return {ddproj:ddproj, ddboxes:ddboxes, myproj:myproj}
          })()
        """

        {@activities, @entries, @options} = @extractActivities info
    
    extractActivities: (info) ->
        entries = []
        reverse = {}
        activities = {}

        for [key, name] in info.ddproj
          if key isnt ""
              activities[key] = name
              reverse[name] = key

        for [a, b, key] in info.ddboxes
          if key isnt ""
              entries.push key
      
        options = for value in _.values(activities).sort()
            [value, reverse[value]]
            
        {activities, entries, options}
          
    ########################
    #   VALUES
    ########################
    
    get_values: ->
        # Return list of [comment, mon, tue, wed, thur, fri, sat, sun] 
        @values = []
        for row in $("form[name=theform] tr", $body)
            inputs = $("input", row)
            if inputs.length <= 1
                # This row doesn't have any values
                continue
            
            row = []
            for input in inputs
                input = $ input
                name = input.attr 'name'
                if name.startsWith("Task") or name.startsWith("Day")
                    row.push input.val()
            
            if row.length > 0
                @values.push row
        
        return
          
    ########################
    #   DAYS
    ########################
    
    get_days: ->
        daysRow = $("form[name=theform] tr:eq(0)", $body)
        @days = for day in $("td.weekday, td.weekend", daysRow)
            txt = $(day).text()
            if txt.length is 0 then continue
            txt
          
    ########################
    #   INTERESTING LINKS
    ########################
    
    get_links: ->
        selectors = 
            choices: 'span.arch a'
            options: '.notonprint'
            calendar: 'input[type=image]'
            help: 'a[target=helpwin]'
            prev: 'table[border=0] a:eq(0)'
            next: 'table[border=0] a:eq(1)'
            copy: 'table[border=0] a:eq(2)'
            print: 'table[border=0] a:eq(3)'
        
        @links = links =
            logoff: {href:"/auth.php/logoff.php", text:"Log off"}
            
        for own name, selector of selectors
            next = $ selector, $body
            links[name] = {href:next.attr("href"), text:next.text()}
        
        links.prev.text = "Last Week"
        links.next.text = "Next Week"
        links.choices.text = links.choices.text.replace("(", "").replace(")", "")
        links
          
    ########################
    #   WEEKS
    ########################
    
    get_weeks: ->
        # Get the weeks in their current form
        weeks = $('table:last', $body)
        
        # Add 'child' class where necessary
        $('a', weeks).addClass 'child'
        $('td.oktxt', weeks).addClass 'child'
        $(".greytxt", weeks).addClass "child"
        
        # Extract the weeks and hours for those weeks
        info = for c in $(".child", weeks)
            c = $(c)
            [c.text(), c.attr 'href']
            
        @weeks = @extractWeeks info
    
    extractWeeks: (weeks) ->
        # Return list of (day, month, hours)
        for [week, href] in weeks
            text = week.replace('.00', '').replace('-', '0').replace(/\s+/g, ' ')
            match = /(\d+).(\w+).([\d\.]+)/.exec text
            [match[1], match[2], match[3], href]
          
    ########################
    #   HIDDEN
    ########################
    
    get_hidden: ->
        hidden = {}
        for tag in $("input[type=hidden]", $body)
            tag = $ tag
            hidden[tag.attr 'name'] = tag.attr 'value'
        
        # Ensure scriptdone is 1
        hidden.scriptdone = '1'
        
        @hidden = hidden
          
    ########################
    #   COPYRIGHT
    ########################
    
    get_copyright: ->
        @copyright = $("p:last", $body).text().trim()
          
########################
#   EXPORT
########################

exports ?= window
exports.makeScraper = makeScraper
