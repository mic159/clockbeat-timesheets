describe 'Scraping', ->
    describe "Title", ->
        scraper.get_title()
            
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
