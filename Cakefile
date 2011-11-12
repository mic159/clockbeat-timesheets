{spawn} = require 'child_process'
watch = require 'watch'

task 'watch', ->
    spawn './bin/coffee.sh', [], customFds:[0..2]
    watch.createMonitor 'templates', (monitor) ->
        monitor.on "changed", ->
            spawn './bin/jade.sh', [], customFds:[0..2]
