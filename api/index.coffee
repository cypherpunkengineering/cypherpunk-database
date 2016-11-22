# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

wiz.package 'cypherpunk.backend.api'

class cypherpunk.backend.api.base extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.support

require './admin'
require './user'
require './affiliate'
require './transaction'

require './radius'

require './v0'

class cypherpunk.backend.api.module extends cypherpunk.backend.api.base
	load: () =>
		# create cypherpunkDB driver
		@mongoURI = 'mongodb://localhost:27017/cypherpunk'
		@cypherpunkDB = new wiz.framework.http.database.mongo.driver(@server, this, @mongoURI)

		@admin = @routeAdd new cypherpunk.backend.api.admin.resource(@server, this, 'admin')
		@user = @routeAdd new cypherpunk.backend.api.user.resource(@server, this, 'user')
		@affiliate = @routeAdd new cypherpunk.backend.api.affiliate.resource(@server, this, 'affiliate')
		@transaction = @routeAdd new cypherpunk.backend.api.transaction.resource(@server, this, 'transaction')

		@radius = @routeAdd new cypherpunk.backend.api.radius.resource(@server, this, 'radius')

		@v0 = @routeAdd new cypherpunk.backend.api.v0.module(@server, this, 'v0')

	init: () =>
		@cypherpunkDB.init()
		super()

# vim: foldmethod=marker wrap
