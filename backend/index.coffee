# wiz-framework: J's HTML5/NodeJS web application framework
#
# Copyright 2012 J. Maurice <j@wiz.biz>
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of version 3 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

require '..'
require './database'
require './messaging'

wiz.package 'wiz.framework.backend'

# worker loop for tasks
class wiz.framework.backend.worker
	quiet: false
	running : false
	interval : 30 * 1000
	rundelay : 3 * 1000
	pending : 0
	waitmax : 5
	waited : 0

	constructor : (@parent) ->
		# wiz.log.debug 'creating worker...'

	init : (listenOnSocket) =>
		# setup worker to run every X secs and manually start first run
		if @rundelay > 0
			setTimeout @run, @rundelay
		if @interval > 0
			setInterval @run, @interval

	onDeadlock : () =>
		wiz.log.alert 'deadlock!!'

	# worker main method
	run : () =>
		# ensure only one call at a time
		if @running
			@waited += 1
			wiz.log.err 'waiting! previous call still running!'
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

	# override this
	work : () =>
		@finish()

	queueTask : (taskName, task) =>
		wiz.log.info "queueing task #{taskName}"
		setTimeout task, 100
		@pending += 1

	onTaskCompleted : (taskName) =>
		wiz.log.debug "completed task #{taskName}"
		@pending -= 1

		# check if any pending tasks
		if @pending > 0
			wiz.log.debug "waiting on #{@pending} pending tasks"
			return

		setTimeout @onAllTasksCompleted, 500

	onAllTasksCompleted : () =>
		return if not @running or @pending > 0
		wiz.log.info 'all tasks completed'
		@finish()

	# called from work() when all work is completed
	finish : () =>
		return if not @running or @pending > 0
		wiz.log.debug 'worker finished' unless @quiet
		@running = false
		@cleanup()

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
			wiz.log.err "mapReduce error for #{output.out}: #{err}"
			console.log err
			@onAllMapReduceTasksCompleted client
			return

		if @pendingMapReduce == 0
			@onAllMapReduceTasksCompleted client

	onAllMapReduceTasksCompleted : (client) =>
		wiz.log.debug 'all mapReduce tasks completed'
		# disconnect from database
		if client
			try
				client.close()
			catch e
				wiz.log.err 'onAllTasksCompleted: exception while disconnecting from database: ' + e.toString()

# vim: foldmethod=marker wrap
