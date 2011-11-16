{spawn} = require 'child_process'
watch = require 'watch'

runJade = -> spawn './bin/jade.sh', [], customFds:[0..2]
runStylus = -> spawn './bin/stylus.sh', [], customFds:[0..2]
runCoffee = -> spawn './bin/coffee.sh', [], customFds:[0..2]

startWatching = ->
    runJade()
    runCoffee()
    runStylus()
    
    watch.createMonitor 'templates', (monitor) ->
        monitor.on "changed", ->
            runJade()
    
    watch.createMonitor 'src', (monitor) ->
        monitor.on "changed", (f) ->
            if f[-5..] == '.styl'
                runStylus()

task 'watch', startWatching
task 'server', ->
    spawn './bin/run.sh', [], customFds:[0..2]
    startWatching()
