
{exec} = require 'child_process'

task 'compile', 'compile CoffeeScript sources', () ->
	exec 'coffee -c -o lib src', (err, stdout, stderr) ->
	    throw err if err
	    console.log stdout + stderr
	console.log "compiled"

task 'test', () ->
	exec 'nodeunit --reporter eclipse test/*-test.*', (err, stdout, stderr) ->
	    throw err if err
	    console.log stdout + stderr
