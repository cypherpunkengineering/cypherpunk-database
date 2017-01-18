require './_framework'

wiz.package 'cypherpunk.backend.stripe'

class cypherpunk.backend.stripe extends wiz.framework.thirdparty.stripe

	purchase: (req, res) => #{{{
		return res.send 400, 'missing parameters' unless (req.body?.token? and req.body?.plan?)
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.token is 'string'
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.plan is 'string'

		subscriptionType = cypherpunk.backend.db.subscription.calculateType req?.body?.plan
		subscriptionRenewal = cypherpunk.backend.db.subscription.calculateRenewal req?.body?.plan

		return res.send 400, 'invalid plan' if not subscriptionRenewal or not subscriptionType

		stripeArgs =
			source: req.body.token
			plan: req.body.plan
			email: req.body.email

		@Stripe.customers.create stripeArgs, (stripeError, stripeCustomerData) =>
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
					@onSuccessfulTransaction(req, res, subscription)
	#}}}

	upgrade: (req, res) => #{{{
		# validate plan
		return res.send 400, 'missing parameters' unless req.body?.plan?
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.plan is 'string'
		subscriptionType = cypherpunk.backend.db.subscription.calculateType req?.body?.plan
		subscriptionRenewal = cypherpunk.backend.db.subscription.calculateRenewal req?.body?.plan
		return res.send 400, 'invalid plan' if not subscriptionRenewal or not subscriptionType

		# check to see if the user has a stripe account already
		if req.session.account?.data?.stripeCustomerID
			@upgradeExistingCustomer req, res, subscriptionType, subscriptionRenewal
		else # if not yet a stripe customer, token is necessary
			return res.send 400, 'missing parameters' unless req.body?.token?
			return res.send 400, 'missing or invalid parameters' unless typeof req.body.token is 'string'
			@upgradeNewCustomer req, res, subscriptionType, subscriptionRenewal

	#}}}
	upgradeExistingCustomer: (req, res, subscriptionType, subscriptionRenewal) => #{{{
		# check to see if the user has a stripe account already
		stripeArgs =
			customer: req.session.account?.data?.stripeCustomerID
			plan: req.body.plan

		stripeArgs.source = req.body.token if req.body?.token?

		console.log 'stripeArgs'
		console.log stripeArgs

		@Stripe.subscriptions.create stripeArgs, (stripeError, stripeSubData) =>
			console.log 'customer data from stripe'
			console.log stripeSubData

			# XXX TODO: check for stripe errors, declines, etc.

			console.log stripeError if stripeError
			return res.send 500, stripeError if stripeError

			# gather subscription data for insert() into db
			subscriptionData =
				provider: 'stripe'
				providerPlanID: stripeSubData?.plan?.id
				providerSubscriptionID: stripeSubData?.id
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
				@onSuccessfulTransaction(req, res, subscription)
	#}}}
	upgradeNewCustomer: (req, res, subscriptionType, subscriptionRenewal) => #{{{
		# check to see if the user has a stripe account already
		stripeArgs =
			source: req.body.token
			plan: req.body.plan
			email: req.session?.account?.data?.email

		console.log 'stripeArgs'
		console.log stripeArgs

		@Stripe.customers.create stripeArgs, (stripeError, stripeCustomerData) =>
			console.log 'customer data from stripe'
			console.log stripeCustomerData

			# XXX TODO: check for stripe errors, declines, etc.

			console.log stripeError if stripeError
			return res.send 500, stripeError if stripeError

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
				@onSuccessfulTransaction(req, res, subscription, stripeCustomerData?.id)
	#}}}

	onSuccessfulTransaction: (req, res, subscription, stripeCustomerID) => #{{{
		# pass updated db object to radius database method
		req.server.root.api.user.database.upgrade req, res, req.session.account.id, subscription.id, stripeCustomerID, (req, res, user) =>
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
