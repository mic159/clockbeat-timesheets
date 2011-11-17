querystring = require 'querystring'
{fetchUrl} = require "fetch"
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
    
    url = "http://timesheet.clockbeat.com#{path}?#{query}"
    options =
        method: method
        payload: info
        cookies: cookies
        setEncoding: "binary"
        disableGzip: true
    
    fetchUrl url, options, callback
        
clockbeat = (method) -> (req, res) ->
    data = []
    req.on 'data', (chunk) ->
        data.push chunk.toString()
        
    req.on 'end', () ->
        data = querystring.parse(data.join "")
        cookies = req.session.cookies
        send req.params[0], {method, data, cookies, query:req.query}, (err, meta, data) ->
            cookies = req.session.cookies = meta?.cookieJar?.cookies
            if cookies?
                result = []
                for name, info of cookies
                    for cookie in info
                        result.push "#{cookie.name}=#{cookie.value}"
                req.session.cookies = result
            
            res.header 'Content-Type', 'text/plain'
            res.header 'Content-Length', data.length
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
