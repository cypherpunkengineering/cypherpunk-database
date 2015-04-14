# copyright 2013 J. Maurice <j@wiz.biz>

require '..'

wiz.package 'wiz.framework.daemon'

# worker loop for tasks
class wiz.framework.daemon.worker

	debug: false
	running: false

	rundelay: 3 * 1000
	interval: 30 * 1000

	taskdelay: 1000
	waitmax: 5
	waited: 0

	constructor: (@parent) -> #{{{
		# wiz.log.debug 'creating worker...'
	#}}}

	init: () => #{{{
		# setup worker to run every X secs and manually start first run
		if @rundelay > 0
			wiz.log.info "initial run delay set to #{@rundelay} ms"
			setTimeout @run, @rundelay
		if @interval > 0
			wiz.log.info "run interval set to #{@interval} ms"
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
		wiz.log.info 'work start'
		@running = true
		setTimeout @work, 500
	#}}}

	work: () => #{{{ override this
		@finish()
	#}}}
	finish: () => #{{{ called from work() when all work is completed
		return if not @running or @pendingTask > 0
		wiz.log.info 'work finished'
		@running = false
		@cleanup()
	#}}}
	cleanup: () => #{{{ called from finish() to cleanup between runs
		return {}
	#}}}

	pendingTask: 0
	queueTask: (taskName, task) => #{{{
		wiz.log.info "queueing task #{taskName}" if @debug
		# schedule task according to amount of pending tasks
		setTimeout task, (@taskdelay * @pendingTask)
		@pendingTask += 1
	#}}}
	onTaskCompleted: (taskName) => #{{{
		wiz.log.info "completed task #{taskName}" if @debug
		@pendingTask -= 1

		# check if any pending tasks
		if @pendingTask > 0
			wiz.log.debug "waiting on #{@pendingTask} pending tasks" if @debug
			return

		setTimeout @checkIfAllTasksCompleted, 500
	#}}}
	checkIfAllTasksCompleted: () => #{{{
		return if not @running or @pendingTask > 0
		@onAllTasksCompleted()
	#}}}
	onAllTasksCompleted: () => #{{{ override in child, just needs to call finish()
		wiz.log.info 'all tasks completed'
		@finish()
	#}}}

	pendingMapReduce: 0 # for queueing multiple mapReduce tasks
	queueMapReduceTask: (collection, map, reduce, output) => #{{{
		wiz.assert(collection, "invalid collection: #{collection}")
		wiz.assert(map, "invalid map: #{map}")
		wiz.assert(reduce, "invalid reduce: #{reduce}")
		wiz.assert(output.out, "invalid output.out: #{output.out}")
		@pendingMapReduce += 1
		@queueTask output.out, () =>
			collection.mapReduce map, reduce, output, (err, ret) =>
				@onMapReduceTaskCompleted output, err, ret
	#}}}
	onMapReduceTaskCompleted: (output, err, ret) => #{{{
		@pendingMapReduce -= 1
		# keep track
		@onTaskCompleted output.out

		# check for error
		if err
			wiz.log.err "mapReduce error for #{output.out}: #{err}"
			console.log err
			@onAllMapReduceTasksCompleted()
			return

		if @pendingMapReduce == 0
			@onAllMapReduceTasksCompleted()
	#}}}
	onAllMapReduceTasksCompleted: () => #{{{
		wiz.log.debug 'all mapReduce tasks completed'
	#}}}

# vim: foldmethod=marker wrap
