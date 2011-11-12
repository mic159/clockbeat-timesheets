describe 'Scraping', ->
    ########################
    #   TITLE
    ########################
    
    describe "Title", ->
        it "should get correct title", ->
            result = jasmine.createSpy 'result'
            fakeExtractTitle = spyOn(scraper, 'extractTitle').andReturn result
            
            scraper.get_title()
            expect(fakeExtractTitle).toHaveBeenCalledWith "SomeGuy - Week commencing 07 Nov 2011"
            expect(scraper.title).toBe result

        it 'Should extract name and date from the title', ->
            dates =
                Jan: "January"
                Feb: "February"
                Mar: "March"
                Apr: "April"
                Jun: "June"
                Jul: "July"
                Aug: "August"
                Sep: "September"
                Oct: "October"
                Nov: "November"
                Dec: "December"
                
            for frm, to of dates
                title = "SomeGuy - Week commencing 07 #{frm} 2011"
                info = scraper.extractTitle title
                expect(info).toEqual
                    original:title
                    name: "SomeGuy"
                    date: "07 #{to} 2011"
            
            for name in ["meh", "blah", "some person", "exciting fred"]
                title = "#{name} - Week commencing 03 Oct 2009"
                info = scraper.extractTitle title
                expect(info).toEqual
                    original:title
                    name: name
                    date: "03 October 2009"
                    
    ########################
    #   ACTIVITIES/ENTRIES
    ########################
                    
    describe "Activities", ->
        extractedInfo = 
            ddproj: [
                [ '', '', 'x' ]
                [ '430025', 'AD001 Admin P', '' ]
                [ '512053', 'AD016 Training', '' ]
                [ '490364', 'BM001 P', '' ]
                [ '490366', 'BM002 SI', '' ]
                [ '504370', 'DV010 PU', '' ]
                [ '561313', 'DV015 BPU', '' ]
                [ '430031', 'MT001 MP', '' ]
                [ '430033', 'MT002 MD', '' ]
                [ '120010', 'ZZ001 Annual leave', '' ]
                [ '120012', 'ZZ002 Sick leave', '' ]
                [ '120014', 'ZZ003 Other leave', '' ]
                ]
            ddboxes: [
                [ 'theform', 'Project0', '504370', "" ]
                [ 'theform', 'Project1', '512053', "" ]
                [ 'theform', 'Project2', '120014', "" ]
                [ 'theform', 'Project3', '', "" ]
                [ 'theform', 'Project4', '', "" ]
                [ 'theform', 'Project5', '', "" ]
                ]
            myproj: [
                [ '504370', 'DV010 PU', '' ]
                [ '512053', 'AD016 Training', '' ]
                [ '120014', 'ZZ003 Other leave', '' ]
                ]
        
        it "should get correct activities", ->
            entries = jasmine.createSpy 'entries'
            activities = jasmine.createSpy 'activites'
            fakeExtractActivities = spyOn(scraper, 'extractActivities').andReturn {entries, activities}
            
            scraper.get_activities()
            
            expect(fakeExtractActivities).toHaveBeenCalledWith extractedInfo
            expect(scraper.entries).toBe entries
            expect(scraper.activities).toBe activities
        
        it "should make entries to be a list of nonempty keys from ddboxes", ->
            {entries} = scraper.extractActivities extractedInfo
            expect(entries).toEqual ['504370', '512053', '120014']
        
        it "should make activities to be a map of keys to activity name", ->
            {activities} = scraper.extractActivities extractedInfo
            expect(activities).toEqual 
                '120010': 'ZZ001 Annual leave'
                '120012': 'ZZ002 Sick leave'
                '120014': 'ZZ003 Other leave'
                '430025': 'AD001 Admin P'
                '430031': 'MT001 MP'
                '430033': 'MT002 MD'
                '490364': 'BM001 P'
                '490366': 'BM002 SI'
                '504370': 'DV010 PU'
                '512053': 'AD016 Training'
                '561313': 'DV015 BPU'
                
    ########################
    #   VALUES
    ########################
    
    describe "Values", ->
        it "should get values for comments and hours each day", ->
            scraper.get_values()
            expect(scraper.values).toEqual [
                [ '', '', '8.00', '8.00', '8.00', '8.00', '', '' ]
                [ '', '', '', '', '', '', '', '' ]
                [ 'Jury Duty', '8.00', '', '', '', '', '', '' ]
                [ '', '', '', '', '', '', '', '' ]
                [ '', '', '', '', '', '', '', '' ]
                [ '', '', '', '', '', '', '', '' ]
                ]
                
    ########################
    #   DAYS
    ########################
    
    describe "Days", ->
        it "should get dates for this week", ->
            scraper.get_days()
            expect(scraper.days).toEqual [
                "07 Nov" 
                "08 Nov" 
                "09 Nov" 
                "10 Nov" 
                "11 Nov" 
                "12 Nov" 
                "13 Nov"
            ]
            
    ########################
    #   LINKS
    ########################
    
    describe "Links", ->
        it "should get href and text for some of the more important links on the page", ->
            scraper.get_links()
            expect(scraper.links).toEqual
                logoff:
                    href: '/auth.php/logoff.php'
                    text: 'Log off'
                choices:
                    href: '?archivestate=1'
                    text: 'Show archived choices'
                options:
                    href: 'options.php'
                    text: 'Options'
                calendar:
                    href: ''
                    text: ''
                help: 
                    href: '../help/timeworked_help.html'
                    text: 'Help'
                prev: 
                    href: 'timeworked.php?start=1320062400&name=624967'
                    text: 'Last Week'
                next: 
                    href: 'timeworked.php?start=1321272000&name=624967'
                    text: 'Next Week'
                copy: 
                    href: 'timeworked.php?carryforward=1&start=1320667200&name=624967'
                    text: 'Copy previous activities'
                print:
                    href: 'print.php?start=1320667200&name=624967'
                    text: 'Print'
            
    ########################
    #   LINKS
    ########################
    
    describe 'Weeks', ->
        extracted = [
            [' 19 Sep \n        40.00 \n      ', 'timeworked.php?start=1316433600&name=624967']
            [' 26 Sep \n        40.00 \n      ', 'timeworked.php?start=1317038400&name=624967']
            [' 03 Oct \n        40.00 \n      ', 'timeworked.php?start=1317643200&name=624967']
            [' 10 Oct \n        40.00 \n      ', 'timeworked.php?start=1318248000&name=624967']
            [' 17 Oct \n        40.00 \n      ', 'timeworked.php?start=1318852800&name=624967']
            [' 24 Oct \n        40.00 \n      ', 'timeworked.php?start=1319457600&name=624967']
            [' 31 Oct \n        40.00 \n      ', 'timeworked.php?start=1320062400&name=624967']
            ['\n       07 Nov 40.00 \n    ', '']
            ]
  
        it "should get correct weeks", ->
            result = jasmine.createSpy 'result'
            fakeExtractWeeks = spyOn(scraper, 'extractWeeks').andReturn result
            
            scraper.get_weeks()
            expect(fakeExtractWeeks).toHaveBeenCalledWith extracted
            expect(scraper.weeks).toBe result
  
        it "should extract day, month and hours from the weeks", ->
            weeks = scraper.extractWeeks extracted
            expect(weeks).toEqual [
                [ '19', 'Sep', '40', 'timeworked.php?start=1316433600&name=624967']
                [ '26', 'Sep', '40', 'timeworked.php?start=1317038400&name=624967']
                [ '03', 'Oct', '40', 'timeworked.php?start=1317643200&name=624967']
                [ '10', 'Oct', '40', 'timeworked.php?start=1318248000&name=624967']
                [ '17', 'Oct', '40', 'timeworked.php?start=1318852800&name=624967']
                [ '24', 'Oct', '40', 'timeworked.php?start=1319457600&name=624967']
                [ '31', 'Oct', '40', 'timeworked.php?start=1320062400&name=624967']
                [ '07', 'Nov', '40', '']
                ]
