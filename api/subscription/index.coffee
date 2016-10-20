# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/acct/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

wiz.package 'cypherpunk.backend.api.subscription'

class cypherpunk.backend.api.subscription.resource extends cypherpunk.backend.api.base
	database: null

	init: () =>
		#@database = new cypherpunk.backend.db.subscription(@server, this, @parent.wizDB)
		# api methods
		@routeAdd new cypherpunk.backend.api.subscription.status(@server, this, 'status')
		super()

class cypherpunk.backend.api.subscription.status extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.customer
	handler: (req, res) =>

		start = new Date()
		expiration = new Date(+start)
		expiration.setDate(start.getDate() + 100)

		out =
			type: 'premium'
			renewal: 'monthly'
			expiration: wiz.framework.util.datetime.unixTS(expiration)

		#console.log out
		res.send 200, out

# vim: foldmethod=marker wrap
