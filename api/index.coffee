# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

wiz.package 'cypherpunk.backend.api'

class cypherpunk.backend.api.base extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.admin

require './staff'
require './customer'
require './transaction'

require './v0'

class cypherpunk.backend.api.module extends cypherpunk.backend.api.base
	mongo: null

	#{{{ database config
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
	load: () =>
		# create cypherpunkDB driver
		@cypherpunkDB = new wiz.framework.http.database.mongo.driver(@server, this, @mongoConfig, @mongoServerOptions, @mongoDbOptions)

		@staff = @routeAdd new cypherpunk.backend.api.staff.resource(@server, this, 'staff')
		@customer = @routeAdd new cypherpunk.backend.api.customer.resource(@server, this, 'customer')
		@transaction = @routeAdd new cypherpunk.backend.api.transaction.resource(@server, this, 'transaction')

		@v0 = @routeAdd new cypherpunk.backend.api.v0.module(@server, this, 'v0')

	init: () =>
		@cypherpunkDB.init()
		super()

# vim: foldmethod=marker wrap
