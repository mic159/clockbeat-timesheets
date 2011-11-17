querystring = require 'querystring'
{FetchStream} = require "fetch"
express = require 'express'
{_} = require 'underscore'

########################
##   CLOCKBEAT
########################
        
send = (path, {method, data, cookies, query}={}, callback) ->
    info = ""
    method ?= "GET"
    if method is "POST"
        info = querystring.stringify data

    if path[0] isnt "/"
        path = "/#{path}"
    
    captured = {cb:callback}
    
    query ?= ""
    query = querystring.stringify query
    fetch = new FetchStream "http://timesheet.clockbeat.com#{path}?#{query}",
        method: method
        payload: info
        cookies: cookies
        
    chunks = []
    fetch.on 'data', (chunk) ->
        chunks.push chunk
            
    fetch.on 'end', () ->
        captured.cb {data:chunks.join(""), meta:captured.meta}
        captured.cb = ->
    
    fetch.on 'meta', (meta) ->
        captured.meta = meta
        
    # Make sure we catch errors
    fetch.on 'error', (e) ->
        captured.cb "", e.message
        captured.cb = ->
        
clockbeat = (method) -> (req, res) ->
    data = []
    req.on 'data', (chunk) ->
        data.push chunk.toString()
        
    req.on 'end', () ->
        data = querystring.parse(data.join "")
        cookies = req.session.cookies
        send req.params[0], {method, data, cookies, query:req.query}, ({data, meta}, error) ->
            cookies = req.session.cookies = meta?.cookieJar?.cookies
            if cookies?
                result = []
                for name, info of cookies
                    for cookie in info
                        result.push "#{cookie.name}=#{cookie.value}"
                req.session.cookies = result
            res.write data
            res.end()
            
clockbeatGET = clockbeat("GET")
clockbeatPOST = clockbeat("POST")

########################
##   CONFIGURE APP
########################

app = exports.app = express.createServer();

app.configure ->
    RedisStore = require('connect-redis')(express)
    app.use express.cookieParser()
    app.use express.session(secret: "mighty_secretive", store:new RedisStore())
    app.set 'views', "#{__dirname}/templates"
    app.set 'view engine', 'jade'
    app.use app.router

app.configure 'development', ->
    app.use express.errorHandler dumpExceptions:true, showStack:true

app.configure 'production', ->
    app.use express.errorHandler()

########################
##   CATCH ALL
########################

app.get '/favicon.ico', (req, res) ->
    res.end()

serveStatic = express.static "#{__dirname}/extension"
missing = (req, res) -> res.send "No such Asset as #{req.url}", 404
app.get '*\.(js|css)', serveStatic, missing

app.get '/clockbeat/*', clockbeatGET
app.post '/clockbeat/*', clockbeatPOST

app.get '*', (req, res) ->
    res.partial 'layout', {node:true}

########################
##   START
########################

app.listen 8000
address = app.address()
console.log "Express server listening on http://#{address.address}:#{address.port}"
