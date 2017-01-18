require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

require './_framework/thirdparty/stripe'
require './_framework/thirdparty/sendgrid'

wiz.package 'cypherpunk.backend.api.v0.subscription'

class cypherpunk.backend.api.v0.subscription.module extends cypherpunk.backend.api.base
	database: null
	debug: true

	init: () =>
		@routeAdd new cypherpunk.backend.api.v0.subscription.status(@server, this, 'status')
		super()

class cypherpunk.backend.api.v0.subscription.status extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.free
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.refresh
	handler: (req, res) =>

		# type is free,premium
		# renewal is monthly, semiannually, annually

		out =
			type: req.session.account?.data?.subscriptionPlan or 'free'
			renewal: req.session.account?.data?.subscriptionRenewal or 'none'
			confirmed: (if req.session.account?.data?.confirmed?.toString() == "true" then true else false)
			expiration: req.session.account?.data?.subscriptionExpiration or '0'

		#console.log out
		res.send 200, out

# vim: foldmethod=marker wrap
