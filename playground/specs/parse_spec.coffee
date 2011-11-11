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
