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

		# nuke existing session if any
		wiz.framework.http.account.session.logout(req, res)

		@server.root.api.user.database.findOneByEmail req, res, req.body.email, (req, res, user) =>

			return res.send 409, 'Email already registered' if user isnt null

			cypherpunk.backend.api.v0.subscription.common.doStripePurchase(req, res)
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
		cypherpunk.backend.api.v0.subscription.common.doStripeUpgrade(req, res)
	#}}}

class cypherpunk.backend.api.v0.subscription.common
	@doStripePurchase: (req, res) => #{{{
		return res.send 400, 'missing parameters' unless (req.body?.token? and req.body?.plan?)
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.token is 'string'
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.plan is 'string'

		subscriptionType = cypherpunk.backend.db.subscription.calculateType req?.body?.plan
		subscriptionRenewal = cypherpunk.backend.db.subscription.calculateRenewal req?.body?.plan

		return res.send 400, 'invalid plan' if not subscriptionRenewal or not subscriptionType

		stripeArgs =
			source: req.body.token
			plan: req.body.plan
			email: req.session?.account?.email or req.body.email

		req.server.root.Stripe.customers.create stripeArgs, (stripeError, stripeCustomerData) =>
			console.log 'customer data from stripe'
			console.log stripeCustomerData

			# XXX TODO: check for stripe errors, declines, etc.

			console.log stripeError if stripeError
			return res.send 500, stripeError if stripeError

			userData =
				confirmed: true
				stripeCustomerID: stripeCustomerData?.id

			console.log 'user data'
			console.log userData

			req.server.root.api.user.database.signup req, res, userData, (req2, res2, result) =>
				# get 0th result
				if result instanceof Array then user = result[0] else user = result

				# create session
				req.server.root.account.doUserLogin(req, res, user)

				# gather subscription data for insert() into db
				subscriptionData =
					provider: 'stripe'
					providerPlanID: stripeCustomerData?.subscriptions?.data?[0]?.plan?.id
					providerSubscriptionID: stripeCustomerData?.subscriptions?.data?[0].id
					currentPeriodStartTS: new Date().toISOString()
					currentPeriodEndTS: subscriptionRenewal
					purchaseTS: new Date().toISOString()
					renewalTS: subscriptionRenewal
					active: 'true'

				console.log 'subscription data'
				console.log subscriptionData

				# save transaction in db
				req.server.root.api.subscription.database.insert req, res, subscriptionType, subscriptionData, (req, res, subscription) =>
					# set user's active subscription to this one
					@doStripeTransactionCompletion(req, res, subscription)
	#}}}
	@doStripeUpgrade: (req, res) => #{{{
		return res.send 400, 'missing parameters' unless (req.body?.token? and req.body?.plan?)
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.token is 'string'
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.plan is 'string'

		subscriptionType = cypherpunk.backend.db.subscription.calculateType req?.body?.plan
		subscriptionRenewal = cypherpunk.backend.db.subscription.calculateRenewal req?.body?.plan

		return res.send 400, 'invalid plan' if not subscriptionRenewal or subscriptionType

		stripeArgs =
			source: req.body.token
			plan: req.body.plan
			email: req.session?.account?.email or req.body.email

		# if upgrading an existing account
		if req.session?.account?.id?
			# set new current subscription
			req.session.account.data.subscriptionCurrentID = subscription.id

			# get existing stripe customer ID from user object
			data.stripeCustomerID = req.session.account.data.stripeCustomerID

			# save updated user data in db
			req.server.root.api.user.database.updateCurrentUserData req, res, (req, res, result2) =>
				console.log result2
				res.send 200

			# go no further
			return

		req.server.root.Stripe.customers.create stripeArgs, (stripeError, stripeCustomerData) =>
			console.log 'customer data from stripe'
			console.log stripeCustomerData

			# XXX TODO: check for stripe errors, declines, etc.

			console.log stripeError if stripeError
			return res.send 500, stripeError if stripeError

			data =
				confirmed: true
				plan: req?.body?.plan
				type: subscriptionType
				renewal: subscriptionRenewal
				currentPeriodStart: new Date().toISOString()
				currentPeriodEnd: subscriptionRenewal
				stripeSubscriptionID: stripeCustomerData?.subscriptions?.data?[0]

			console.log 'our data'
			console.log data

			# save transaction in db
			req.server.root.api.subscription.database.insertOneFromStripePurchase req, res, data, (req, res, subscription) =>

				# if no account yet, create one
				data.stripeCustomerID = stripeCustomerData.id
				data.subscriptionCurrentID = subscription.id
				req.server.root.api.user.database.signup req, res, data, (req2, res2, result) =>

					# get 0th result
					if result instanceof Array then user = result[0] else user = result

					# send purchase mail
					req.server.root.sendPurchaseMail user, (sendgridError) =>
						if sendgridError
							wiz.log.err "Unable to send email to #{user?.data?.email} due to sendgrid error"
							console.log sendgridError

					# create session for new account
					out = req.server.root.account.doUserLogin(req, res, user)
					res.send 200, out
	#}}}
	@doStripeTransactionCompletion: (req, res, subscription) => #{{{
		# pass updated db object to radius database method
		req.server.root.api.user.database.upgrade req, res, req.session.account.id, subscription.id, (req, res, user) =>
			# send purchase mail
			req.server.root.sendPurchaseMail user, (sendgridError) =>
				if sendgridError
					wiz.log.err "Unable to send email to #{user?.data?.email} due to sendgrid error"
					console.log sendgridError

			# create session for new account
			out = req.server.root.account.doUserLogin(req, res, user)
			res.send 200, out
	#}}}

# vim: foldmethod=marker wrap
