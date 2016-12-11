# wiz manager daemon reference implementation
# copyright 2014 J. Maurice <j@wiz.biz>

# framework
require './_framework'
require './_framework/daemon/worker'
require './_framework/util/strval'
require './_framework/util/datetime'

wiz.package 'cypherpunk.backend.worker'

class cypherpunk.backend.worker extends wiz.framework.daemon.worker

	debug: true

	statsHourlyCollection: 'statsHourly'

	statsDailyCollection: 'statsDaily'
	statsDailyMapReduceCollection: 'statsDailyMapReduce'

#	statsWeeklyCollection: 'statsWeekly'
#	statsMonthlyCollection: 'statsMonthly'

	taskdelay: 500 # avoid getting banned
	interval: 600 * 1000 # 10 minutes
	waitmax: 5 # if worker is busy after 5 attempts, declare deadlock
	runstate: null

	fetchFrontendStatsHours: 3

	init: (cb) => #{{{
		super (err) =>
			systemJS =
				'dayFromDate': @constructor.prototype.dayFromDate
				'dayhourFromDate': @constructor.prototype.dayhourFromDate
			@saveSystemJS systemJS, () =>
				wiz.log.info "mongo initialization completed"
				cb(err) if cb

		wiz.log.info "worker initialization completed"
		cb() if cb
	#}}}
	work: () => #{{{
		@runstate = 'start'
		@finish()
	#}}}
	cleanup: () => #{{{
		@runstate = null
	#}}}

	onDeadlock: () =>
		throw new Error 'deadlock!'

# vim: foldmethod=marker wrap
