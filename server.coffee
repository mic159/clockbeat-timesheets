querystring = require 'querystring'
express = require 'express'
http = require 'http'

########################
##   CLOCKBEAT
########################
        
send = (path, {method, data}, callback) ->
    info = ""
    if method is "POST"
        info = querystring.stringify data
        
    headers =
        'Content-Length':info.length
        'Content-Type':'application/x-www-form-urlencoded'
        
    captured = {cb:callback, request}
    if path[0] isnt "/"
        path = "/#{path}"
    options = {host:"timesheet.clockbeat.com", 80, path, method, headers}
    
    request = captured.request = http.request options, (response) ->
        response.setEncoding('utf8')
        chunks = []
        response.on 'data', (chunk) ->
            chunks.push chunk
            
        response.on 'end', () ->
            captured.cb chunks.join ""
            captured.cb = ->
    
    # Make sure we catch errors
    request.on 'error', (e) ->
        captured.cb "", e.message
        captured.cb = ->
    
    # Write to the request
    request.write info
    request.end()

    # Application level timeout
    # Default two minutes is too long, and currently no way to change it
    setTimeout ->
        captured.request.abort()
        captured.cb "", "timeout"
        captured.cb = ->
    , 5000
        
clockbeat = (method) -> (req, res) ->
    data = []
    req.on 'data', (chunk) ->
        data.push chunk.toString()
        
    req.on 'end', () ->
        data = querystring.parse(data.join "")
        send req.params[0], {method, data}, (result, error) ->
            res.write result
            res.end()
            
clockbeatGET = clockbeat("GET")
clockbeatPOST = clockbeat("POST")

########################
##   CONFIGURE APP
########################

app = exports.app = express.createServer();

app.configure ->
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
