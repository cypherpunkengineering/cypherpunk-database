# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/acct/session'
require './_framework/http/db/mongo'

wiz.package 'cypherpunk.backend.api'

class cypherpunk.backend.api.base extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.admin

require './user'
require './vpn'

class cypherpunk.backend.api.module extends cypherpunk.backend.api.base
	mongo: null

	#{{{ database config
	cypherpunkDBmongo:
		mongoConfig:
			hostname: 'localhost'
			database: 'cypherpunk'

		mongoServerOptions:
			auto_reconnect: true
			poolSize: 2

		mongoDbOptions:
			reaper: true
			safe: true
	#}}}
	#{{{ database config
	wizDBmongo:
		mongoConfig:
			hostname: 'localhost'
			database: 'wizacct'

		mongoServerOptions:
			auto_reconnect: true
			poolSize: 2

		mongoDbOptions:
			reaper: true
			safe: true
	#}}}
	load: () =>
		# create db driver
		@cypherpunkDB = new wiz.framework.http.database.mongo.driver(@server, this, @cypherpunkDBmongo.mongoConfig, @cypherpunkDBmongo.mongoServerOptions, @cypherpunkDBmongo.mongoDbOptions)
		@wizDB = new wiz.framework.http.database.mongo.driver(@server, this, @wizDBmongo.mongoConfig, @wizDBmongo.mongoServerOptions, @wizDBmongo.mongoDbOptions)

		@user = @routeAdd new cypherpunk.backend.api.user.resource(@server, this, 'user')
		@vpn = @routeAdd new cypherpunk.backend.api.vpn.resource(@server, this, 'vpn')

	init: () =>
		@cypherpunkDB.init()
		@wizDB.init()
		super()

# vim: foldmethod=marker wrap
