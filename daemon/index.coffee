# copyright 2013 J. Maurice <j@wiz.biz>

require '..'

wiz.package 'wiz.framework.daemon'

# worker loop for tasks
class wiz.framework.daemon.worker

	quiet: false
	running: false
	interval: 30 * 1000
	rundelay: 3 * 1000
	pending: 0
	waitmax: 5
	waited: 0

	constructor: (@parent) -> #{{{
		# wiz.log.debug 'creating worker...'
	#}}}

	init: () => #{{{
		# setup worker to run every X secs and manually start first run
		if @rundelay > 0
			setTimeout @run, @rundelay
		if @interval > 0
			setInterval @run, @interval
	#}}}

	onRunWait: () => #{{{
		wiz.log.err 'waiting! previous call still running!'
	#}}}
	onDeadlock: () => #{{{
		wiz.log.alert 'deadlock!!'
	#}}}

	run: () => #{{{ worker main method

		# ensure only one call at a time
		if @running
			@waited += 1
			@onRunWait()
			if @waited >= @waitmax
				@onDeadlock()
				return
			return
		else
			@waited = 0

		# start
		wiz.log.debug 'worker started' unless @quiet
		@running = true
		setTimeout @work, 500
	#}}}

	work: () => #{{{ override this
		@finish()
	#}}}
	queueTask: (taskName, task) => #{{{
		wiz.log.info "queueing task #{taskName}"
		setTimeout task, 100
		@pending += 1
	#}}}
	onTaskCompleted: (taskName) => #{{{
		wiz.log.debug "completed task #{taskName}"
		@pending -= 1

		# check if any pending tasks
		if @pending > 0
			wiz.log.debug "waiting on #{@pending} pending tasks"
			return

		setTimeout @onAllTasksCompleted, 500
	#}}}
	onAllTasksCompleted: () => #{{{
		return if not @running or @pending > 0
		wiz.log.info 'all tasks completed'
		@finish()
	#}}}
	finish: () => #{{{ called from work() when all work is completed
		return if not @running or @pending > 0
		wiz.log.debug 'worker finished' unless @quiet
		@running = false
		@cleanup()
	#}}}
	cleanup: () => #{{{ called from finish() to cleanup between runs
		return {}
	#}}}

	pendingMapReduce: 0 # for queueing multiple mapReduce tasks
	queueMapReduceTask: (client, collection, map, reduce, output) => #{{{
		@pendingMapReduce += 1
		@queueTask output.out, () =>
			collection.mapReduce map, reduce, output, (err, ret) =>
				@onMapReduceTaskCompleted client, output, err, ret
	#}}}
	onMapReduceTaskCompleted: (client, output, err, ret) => #{{{
		@pendingMapReduce -= 1
		# keep track
		@onTaskCompleted output.out

		# check for error
		if err
			wiz.log.err "mapReduce error for #{output.out}: #{err}"
			console.log err
			@onAllMapReduceTasksCompleted client
			return

		if @pendingMapReduce == 0
			@onAllMapReduceTasksCompleted client
	#}}}
	onAllMapReduceTasksCompleted: (client) => #{{{
		wiz.log.debug 'all mapReduce tasks completed'
		# disconnect from database
		if client
			try
				client.close()
			catch e
				wiz.log.err 'onAllTasksCompleted: exception while disconnecting from database: ' + e.toString()
	#}}}

# vim: foldmethod=marker wrap
