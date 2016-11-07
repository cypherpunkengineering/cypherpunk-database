# copyright 2013 J. Maurice <j@wiz.biz>

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
		#@database = new cypherpunk.backend.db.subscription(@server, this, @parent.parent.cypherpunkDB)
		# api methods
		@routeAdd new cypherpunk.backend.api.v0.subscription.status(@server, this, 'status')
		@routeAdd new cypherpunk.backend.api.v0.subscription.purchase(@server, this, 'purchase', 'POST')
		@routeAdd new cypherpunk.backend.api.v0.subscription.upgrade(@server, this, 'upgrade', 'POST')
		super()

class cypherpunk.backend.api.v0.subscription.status extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.customerFree
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.refresh
	handler: (req, res) =>

		# type is free,premium
		# renewal is monthly, semiannually, annually

		out =
			type: req.session.account?.data?.subscriptionType or 'free'
			renewal: req.session.account?.data?.subscriptionRenewal or 'none'
			confirmed: req.session.account?.confirmed
			expiration: req.session.account?.data?.subscriptionExpiration or 'none'

		#console.log out
		res.send 200, out

class cypherpunk.backend.api.v0.subscription.purchase extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	handlerOPTIONS: (req, res) => #{{{
		res.setHeader 'Access-Control-Allow-Origin', '*'
		res.setHeader 'Access-Control-Allow-Methods', 'POST,OPTIONS'
		res.setHeader 'Access-Control-Allow-Headers', 'Content-type, Cookie'
		super(req, res)
	#}}}
	handler: (req, res) => #{{{
		return res.send 400, 'missing parameters' unless (req.body?.email?)
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.email is 'string'
		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.email_valid(req.body.email)

		@server.root.api.customer.database.findOneByEmail req, res, req.body.email, (req, res, user) =>

			return res.send 409, 'Email already registered' if user isnt null

			cypherpunk.backend.api.v0.subscription.common.purchase(req, res)
	#}}}

class cypherpunk.backend.api.v0.subscription.upgrade extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	mask: cypherpunk.backend.server.power.mask.auth
	nav: false

	handlerOPTIONS: (req, res) => #{{{
		res.setHeader 'Access-Control-Allow-Origin', '*'
		res.setHeader 'Access-Control-Allow-Methods', 'POST,OPTIONS'
		res.setHeader 'Access-Control-Allow-Headers', 'Content-type, Cookie'
		super(req, res)
	#}}}
	handler: (req, res) => #{{{
		cypherpunk.backend.api.v0.subscription.common.purchase(req, res)
	#}}}

class cypherpunk.backend.api.v0.subscription.common
	@purchase: (req, res) => #{{{
		return res.send 400, 'missing parameters' unless (req.body?.token? and req.body?.plan?)
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.token is 'string'
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.plan is 'string'

		subscriptionStart = new Date()
		subscriptionExpiration = new Date(+subscriptionStart)

		console.log req.body.plan[0...7]
		console.log req.body.plan[0...11]

		if req.body.plan[0...7] == "monthly"
			subscriptionRenewal = "monthly"
			subscriptionExpiration.setDate(subscriptionStart.getDate() + 30)
		else if req.body.plan[0...12] == "semiannually"
			subscriptionRenewal = "semiannually"
			subscriptionExpiration.setDate(subscriptionStart.getDate() + 180)
		else if req.body.plan[0...8] == "annually"
			subscriptionRenewal = "annually"
			subscriptionExpiration.setDate(subscriptionStart.getDate() + 365)
		else
			return res.send 400, "Invalid plan selected"

		subscriptionData =
			confirmed: true
			subscriptionType: 'premium'
			subscriptionRenewal: subscriptionRenewal
			subscriptionExpiration: subscriptionExpiration

		email = req.session?.account?.email
		email ?= req.body.email

		stripeArgs =
			source: req.body.token
			plan: req.body.plan
			email: email

		@purchaseStripe req, res, stripeArgs, (stripeCustomerData) =>

			# XXX TODO: check for stripe errors, declines, etc.

			# if upgrading, just update session, will be auto-saved to db
			if req.session?.account?.id?
				req.session.account.data.subscriptionType = subscriptionData.subscriptionType
				req.session.account.data.subscriptionRenewal = subscriptionData.subscriptionRenewal
				req.session.account.data.subscriptionExpiration = subscriptionData.subscriptionExpiration

				req.server.root.api.customer.database.updateCurrentUserData req, res, (result2) =>
					# TODO: add transaction ID etc.
					res.send 200, result2

				return

			# if no account yet, create one
			req.server.root.api.customer.database.signup req, res, subscriptionData, (result) =>

				if result instanceof Array
					user = result[0]
				else
					user = result

				req.server.root.api.customer.sendPurchaseMail user, (sendgridError) =>
					if sendgridError
						wiz.log.err "Unable to send email to #{user?.data?.email} due to sendgrid error"
						console.log sendgridError

				out = req.server.root.account.authenticate.password.doUserLogin(req, res, user)
				res.send 200, out
	#}}}
	@purchaseStripe: (req, res, stripeArgs, cb) => #{{{

		try
			req.server.root.Stripe.customers.create stripeArgs, (stripeError, stripeCustomerData) =>
				console.log stripeError if stripeError
				return res.send 500, stripeError if stripeError
				console.log 'customer data from stripe'
				console.log stripeCustomerData
				cb(stripeCustomerData)

		catch e
			console.log e
			res.send 500
	#}}}

# vim: foldmethod=marker wrap
