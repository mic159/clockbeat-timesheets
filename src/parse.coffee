exports ?= window
do (exports) ->
  exports.makeScraper = (window, $) ->    
    scraper = 
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
            
      ########################
      #   DAYS
      ########################
      
      get_days: ->
            
      ########################
      #   INTERESTING LINKS
      ########################
      
      get_links: ->
            
      ########################
      #   UPDATE URL
      ########################
      
      get_updateUrl: ->
            
      ########################
      #   WEEKS
      ########################
      
      get_weeks: ->
