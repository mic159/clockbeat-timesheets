#!/usr/bin/env coffee

fs = require 'fs'
jsdom = require 'jsdom'
    
# Set Underscore as a global
global._ = require("underscore")._

# Add some methods to built in objects
require '../extension/libraries/iefixes'

loadTestPage = (cb, {context}={}) ->
  jsdom.env
    html: 'page.html'
    scripts: ['../extension/libraries/jquery.js']
    done: (errors, window) ->
      cb.call context, window.$

if module.parent
  exports.loadTestPage = loadTestPage
else
  # Loaded as a script
  {makeScraper} = require '../src/parse'
  loadTestPage ($) ->
    makeScraper($, $("body")).start()
