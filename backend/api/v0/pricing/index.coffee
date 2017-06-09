# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

wiz.package 'cypherpunk.backend.api.v0.pricing'

class cypherpunk.backend.api.v0.pricing.module extends cypherpunk.backend.api.base
	database: null
	debug: true

	init: () =>
		@routeAdd new cypherpunk.backend.api.v0.pricing.plans(@server, this, 'plans', 'POST')
		super()

class cypherpunk.backend.api.v0.pricing.plans extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	handler: (req, res) =>

		out = cypherpunk.backend.pricing.getDefaultPlans()
		console.log out
		res.send 200, out

# vim: foldmethod=marker wrap
