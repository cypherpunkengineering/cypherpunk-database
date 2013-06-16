# copyright 2013 wiz technologies inc.

cluster = require 'cluster'

class wiz.base # base app object

	constructor: () -> #{{{
		@config =
			workers: 2
	#}}}
	start: () => #{{{ main process
		@master() if cluster.isMaster
		@worker() if cluster.isWorker
	#}}}
	master: () => #{{{ main process of master supervisor process
		wiz.log.notice "*** MASTER #{process.pid} START"

		# restart worker processes if they die
		cluster.on 'exit', (worker, code, signal) ->
			wiz.log.crit "WORKER #{worker.process.pid} DIED! (SIGNAL #{code})"
			setTimeout cluster.fork, 500

		# spawn X workers
		for i in [1..@config.workers]
			cluster.fork()
	#}}}
	worker: () => #{{{ main process of forked worker processes
		wiz.log.notice "*** WORKER #{process.pid} START"
		@main()
	#}}}
	main: () => #{{{ main process of app
		# for child class
	#}}}

# vim: foldmethod=marker wrap
