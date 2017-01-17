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

		@server.root.api.user.database.findOneByEmail req, res, req.body.email, (req, res, user) =>

			return res.send 409, 'Email already registered' if user isnt null

			cypherpunk.backend.api.v0.subscription.common.purchase(req, res)
	#}}}

class cypherpunk.backend.api.v0.subscription.upgrade extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.base
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

		subscriptionType = cypherpunk.backend.db.subscription.calculateType(req?.body?.plan)
		subscriptionRenewal = cypherpunk.backend.db.subscription.calculateRenewal(req?.body?.plan)

		if !subscriptionRenewal || !subscriptionType
			return res.send 500, 'Invalid Plan'

		subscriptionData =
			confirmed: true
			plan: req?.body?.plan
			type: subscriptionType
			renewal: subscriptionRenewal
			currentPeriodStart: new Date().toISOString()
			currentPeriodEnd: subscriptionRenewal

		stripeArgs =
			source: req.body.token
			plan: req.body.plan
			email: req.session?.account?.email or req.body.email

		@onSuccessfulStripeResult req, res, stripeArgs, subscriptionData, (stripeCustomerData, subscription) =>

			# XXX TODO: check for stripe errors, declines, etc.

			if req.session?.account?.id?
				req.session.account.data.subscriptionCurrentID = subscription.id

				req.server.root.api.user.database.updateCurrentUserData req, res, (req, res, result2) =>
					console.log result2
					res.send 200

				return

			# if no account yet, create one
			subscriptionData.stripeCustomerID = stripeCustomerData.id
			subscriptionData.subscriptionCurrentID = subscription.id
			req.server.root.api.user.database.signup req, res, subscriptionData, (req2, res2, result) =>

				if result instanceof Array
					user = result[0]
				else
					user = result

				req.server.root.sendPurchaseMail user, (sendgridError) =>
					if sendgridError
						wiz.log.err "Unable to send email to #{user?.data?.email} due to sendgrid error"
						console.log sendgridError

				out = req.server.root.account.doUserLogin(req, res, user)
				res.send 200, out
	#}}}
	@onSuccessfulStripeResult: (req, res, stripeArgs, subscriptionData, cb) => #{{{

		try
			req.server.root.Stripe.customers.create stripeArgs, (stripeError, stripeCustomerData) =>
				console.log stripeError if stripeError
				return res.send 500, stripeError if stripeError

				console.log 'user data from stripe'
				console.log stripeCustomerData
				console.log 'subscription data'
				console.log subscriptionData

				# save transaction in db
				req.server.root.api.subscription.database.insertOneFromStripePurchase req, res, subscriptionData, stripeCustomerData?.subscriptions?.data, (req, res, subscription) =>
					cb(stripeCustomerData, subscription)

		catch e
			console.log e
			res.send 500
	#}}}

# vim: foldmethod=marker wrap
