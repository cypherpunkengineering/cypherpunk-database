# wiz-framework
require '..'

# wizbackend package
wizpackage 'wizbackend'
require './database'

# zero message queue
zmq = require 'zmq'

# loop for tasks
class wizbackend.looper
	running : false
	interval : 30 * 1000
	rundelay : 3 * 1000
	pending : 0
	waitmax : 5
	waited : 0

	constructor : (@parent) ->
		wizlog.debug @constructor.name, 'Creating looper...'

	init : (listenOnSocket) =>
		# setup looper to run every X secs and manually start first run
		if @rundelay > 0
			setTimeout @run, @rundelay
		if @interval > 0
			setInterval @run, @interval

	onDeadlock : () =>
		wizlog.alert @constructor.name, 'deadlock!!'

	# looper main method
	run : () =>
		# ensure only one call at a time
		if @running
			@waited += 1
			wizlog.err @constructor.name, 'waiting! previous call still running!'
			if @waited >= @waitmax
				@onDeadlock()
				return
			return
		else
			@waited = 0

		# start
		wizlog.debug @constructor.name, 'looper start'
		@running = true
		setTimeout @work, 500

	# override this
	work : () =>
		@finish()

	queueTask : (taskName, task) =>
		wizlog.info @constructor.name, "queueing task #{taskName}"
		setTimeout task, 100
		@pending += 1

	onTaskCompleted : (taskName) =>
		wizlog.debug @constructor.name, "completed task #{taskName}"
		@pending -= 1

		# check if any pending tasks
		if @pending > 0
			wizlog.debug @constructor.name, "waiting on #{@pending} pending tasks"
			return

		setTimeout @onAllTasksCompleted, 500

	onAllTasksCompleted : () =>
		if @pending > 0
			# more tasks were scheduled! keep waiting...
			return

		wizlog.info @constructor.name, 'all tasks completed'
		@finish()

	# called from work() when all work is completed
	finish : () =>
		wizlog.debug @constructor.name, 'looper end'
		@pending = 0
		@cleanup()
		@running = false

	# called from finish() to cleanup between runs
	cleanup : () => {}

	# for queueing multiple mapReduce tasks
	pendingMapReduce : 0
	queueMapReduceTask : (client, collection, map, reduce, output) =>
		@pendingMapReduce += 1
		@queueTask output.out, () =>
			collection.mapReduce map, reduce, output, (err, ret) =>
				@onMapReduceTaskCompleted client, output, err, ret

	onMapReduceTaskCompleted : (client, output, err, ret) =>
		@pendingMapReduce -= 1
		# keep track
		@onTaskCompleted output.out

		# check for error
		if err
			wizlog.err @constructor.name, "mapReduce error for #{output.out}: #{err}"
			console.log err
			@onAllMapReduceTasksCompleted client
			return

		if @pendingMapReduce == 0
			@onAllMapReduceTasksCompleted client

	onAllMapReduceTasksCompleted : (client) =>
		wizlog.debug @constructor.name, 'all mapReduce tasks completed'
		# disconnect from database
		if client
			try
				client.close()
			catch e
				wizlog.err @constructor.name, 'onAllTasksCompleted: exception while disconnecting from database: ' + e.toString()

# listen on a zmq socket
class wizbackend.listener

	sock : 'tcp://*:0'

	constructor : (@parent, @sock) ->
		# allocate a socket for listening
		@responder = zmq.socket 'rep'

	onMessage : (msg) =>
		wizlog.debug @constructor.name, "onMessage: #{msg}"

	init : () =>
		# listen for messages
		@responder.on 'message', @onMessage
		@responder.bind @sock, (err) =>
			if err
				wizlog.crit @constructor.name, "Cannot bind to socket #{@sock}: #{err}"
				process.exit()

		wizlog.info @constructor.name, "Bound to #{@sock}"

# main manager object
class wizbackend.manager

	constructor : () ->
		wizlog.debug @constructor.name, 'Creating manager...'
		unless @listener
			@listener = new wizbackend.listener(@)
		unless @looper
			@looper = new wizbackend.looper(@)

	init : () =>
		setTimeout @listener.init, 1500
		setTimeout @looper.init, 3000

# vim: foldmethod=marker wrap
