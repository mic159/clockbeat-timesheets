#!/usr/bin/env coffee

fs = require 'fs'
jsdom = require 'jsdom'

loadTestPage = (cb, {context}={}) ->
  jsdom.env
    html: 'page.html'
    scripts: ['../extension/jquery.js']
    done: (errors, window) ->
      cb.call context, window, window.$

if module.parent
  exports.loadTestPage = loadTestPage
else
  # Loaded as a script
  {scrape} = require '../src/parse'
  loadTestPage scrape
