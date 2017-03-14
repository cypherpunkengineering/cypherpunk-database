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

require './subscription'
require './invoice'
require './charge'
require './receipt'
require './refund'

require './network'

require './radius'
require './smartdns'

require './v0'

class cypherpunk.backend.api.module extends cypherpunk.backend.api.base
	load: () =>
		# create cypherpunkDB driver
		@cypherpunkDB = new wiz.framework.http.database.mongo.driver(@server, this, @server.config.mongoURI)

		@admin = @routeAdd new cypherpunk.backend.api.admin.resource(@server, this, 'admin')
		@user = @routeAdd new cypherpunk.backend.api.user.resource(@server, this, 'user')
		@affiliate = @routeAdd new cypherpunk.backend.api.affiliate.resource(@server, this, 'affiliate')

		@subscription = @routeAdd new cypherpunk.backend.api.subscription.resource(@server, this, 'subscription')
		@invoice = @routeAdd new cypherpunk.backend.api.invoice.resource(@server, this, 'invoice')
		@charge = @routeAdd new cypherpunk.backend.api.charge.resource(@server, this, 'charge')
		@receipt = @routeAdd new cypherpunk.backend.api.receipt.resource(@server, this, 'receipt')
		@refund = @routeAdd new cypherpunk.backend.api.refund.resource(@server, this, 'refund')

		@network = @routeAdd new cypherpunk.backend.api.network.module(@server, this, 'network')

		@radius = @routeAdd new cypherpunk.backend.api.radius.resource(@server, this, 'radius')
		@radius.config = @server.config.radiusDB

		@smartdns = @routeAdd new cypherpunk.backend.api.smartdns.resource(@server, this, 'smartdns')
		@smartdns.config = @server.config.smartdnsDB

		@v0 = @routeAdd new cypherpunk.backend.api.v0.module(@server, this, 'v0')

	init: () =>
		@cypherpunkDB.init()
		super()

# vim: foldmethod=marker wrap
