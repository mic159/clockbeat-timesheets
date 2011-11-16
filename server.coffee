express = require 'express'
        
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

app.get '*', (req, res) ->
    res.partial 'layout'

########################
##   START
########################

app.listen 8000
address = app.address()
console.log "Express server listening on http://#{address.address}:#{address.port}"
