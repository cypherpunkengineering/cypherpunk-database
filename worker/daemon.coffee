# wiz manager daemon reference implementation
# copyright 2014 J. Maurice <j@wiz.biz>

# framework
require './_framework'
require './_framework/daemon/worker'
require './_framework/util/strval'

require './worker'

wiz.package 'cypherpunk.backend.daemon'

wiz.app 'cypherpunk-backend-worker'

class cypherpunk.backend.daemon

	#{{{ database config
	mongoConfig:
		hostname: 'localhost'
		database: 'cypherpunk'

	mongoServerOptions:
		auto_reconnect: true
		socket_timeout: 1000
		poolSize: 2

	mongoDbOptions:
		reaper: true
		safe: true
	#}}}

	constructor: () -> #{{{
		wiz.log.info ''
		wiz.log.info '#################################'
		wiz.log.info 'cypherpunk backend worker startup'
		wiz.log.info '#################################'
		wiz.log.info ''

		@worker = new cypherpunk.backend.worker(@, @mongoConfig, @mongoServerOptions, @mongoDbOptions)
	#}}}
	init: () => #{{{
		@worker.init()
	#}}}

# vim: foldmethod=marker wrap
