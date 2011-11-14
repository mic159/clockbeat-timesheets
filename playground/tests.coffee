#!/usr/bin/env coffee
require '../extension/libraries/iefixes'
jasmine = require 'jasmine-node'
{loadTestPage} = require './parse'
{makeScraper} = require '../src/parse'

loadTestPage (window, $) ->
    # Set scraper as a global for the tests
    global.scraper = makeScraper $, $("body")
    
    # Options for tests
    done = ->
    folder = "#{__dirname}/specs"
    matcher = /._spec\.(coffee|js)$/i
    teamcity = false
    isVerbose = false
    showColors = true
    junitreport = report:false
    
    # Run the tests
    jasmine.executeSpecsInFolder folder, done, isVerbose, showColors, teamcity, matcher, junitreport
