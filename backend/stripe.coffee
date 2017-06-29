require './_framework'
require './_framework/thirdparty/stripe'
require './_framework/util/format'

wiz.package 'cypherpunk.backend.stripe'

class cypherpunk.backend.stripe extends wiz.framework.thirdparty.stripe

	ipn: (req, res) => #{{{
#{{{ sample data
# {
#   "created": 1326853478,
#   "livemode": false,
#   "id": "evt_00000000000000",
#   "type": "charge.succeeded",
#   "object": "data",
#   "request": null,
#   "pending_webhooks": 1,
#   "api_version": "2017-06-05",
#   "data": {
#     "object": {
#       "id": "ch_00000000000000",
#       "object": "charge",
#       "amount": 6900,
#       "amount_refunded": 0,
#       "application": null,
#       "application_fee": null,
#       "balance_transaction": "txn_00000000000000",
#       "captured": true,
#       "created": 1497427916,
#       "currency": "usd",
#       "customer": "cus_00000000000000",
#       "description": null,
#       "destination": null,
#       "dispute": null,
#       "failure_code": null,
#       "failure_message": null,
#       "fraud_details": {
#       },
#       "invoice": "in_00000000000000",
#       "livemode": false,
#       "metadata": {
#       },
#       "on_behalf_of": null,
#       "order": null,
#       "outcome": {
#         "network_status": "approved_by_network",
#         "reason": null,
#         "risk_level": "normal",
#         "seller_message": "Payment complete.",
#         "type": "authorized"
#       },
#       "paid": true,
#       "receipt_email": null,
#       "receipt_number": null,
#       "refunded": false,
#       "refunds": {
#         "object": "list",
#         "data": [
#         ],
#         "has_more": false,
#         "total_count": 0,
#         "url": "/v1/charges/ch_1AUWbYCymPOZwO5rrKVFKdaD/refunds"
#       },
#       "review": null,
#       "shipping": null,
#       "source": {
#         "id": "card_00000000000000",
#         "object": "card",
#         "address_city": null,
#         "address_country": "United States",
#         "address_line1": null,
#         "address_line1_check": null,
#         "address_line2": null,
#         "address_state": null,
#         "address_zip": "96818",
#         "address_zip_check": "pass",
#         "brand": "Visa",
#         "country": "US",
#         "customer": "cus_00000000000000",
#         "cvc_check": "pass",
#         "dynamic_last4": null,
#         "exp_month": 10,
#         "exp_year": 2018,
#         "fingerprint": "fTt4qcLklUAnbpoP",
#         "funding": "credit",
#         "last4": "4242",
#         "metadata": {
#         },
#         "name": "ed",
#         "tokenization_method": null
#       },
#       "source_transfer": null,
#       "statement_descriptor": null,
#       "status": "succeeded",
#       "transfer_group": null
#     }
#   }
# }
#}}}

		payload = req.rawBody
		sigHeader = req.headers['stripe-signature']

		try
			data = @Stripe.webhooks.constructEvent(payload, sigHeader, @options.endpointSecret)
		catch e
			# Invalid payload or signature
			console.log e
			return res.send 400

		#console.log "got valid stripe data"
		#console.log data

		# get stripe customer ID
		stripeCustomerID = null
		stripeCustomerID ?= data.data?.object?.customer
		stripeCustomerID ?= data.data?.object?.id

		# if not found, ignore
		return res.send 200, 'Stripe customer ID not found?' unless stripeCustomerID?

		# lookup cypherpunk account object by stripe customer id
		@server.root.api.user.database.findOneByStripeCustomerID req, res, stripeCustomerID, (req, res, user) =>

			# if not found, ignore
			return res.send 200, 'Cypherpunk account not found!' unless user?.id?

			# proceed based on event type
			switch data.type
				when 'charge.succeeded'
					@onChargeSucceeded(req, res, data, user)
				else
					# send to billing channel on slack
					#@sendSlackNotification(data, user)
					res.send 200, "Unknown Stripe IPN type: #{data?.type}"
	#}}}

	onChargeSucceeded: (req, res, data, user) => #{{{
		return res.send 400, 'missing stripe IPN data object' unless data?.data?.object?
		chargeData = data.data.object
		created = chargeData.created or data.created or Math.floor((new Date()).getTime() / 1000)
		chargeData.created = new Date(created * 1000)
		chargeData.cypherpunk_account_id = user?.id
		chargeData.sourceID = chargeData.source?.id
		chargeData.sourceBrand = chargeData.source?.brand
		chargeData.sourceLast4 = chargeData.source?.last4

		@server.root.api.charge.database.saveFromIPN req, res, 'stripe', chargeData, (req, res, charge) =>
			charge = charge[0] if charge instanceof Array
			console.log charge

			receiptData =
				accountID: charge?.data?.cypherpunk_account_id
				transactionID: charge?.data?.id
				paymentTS: new Date(charge?.data?.created)
				description: "Cypherpunk Privacy Elite subscription"
				method: "Stripe #{charge?.data?.sourceBrand} #{charge?.data?.sourceLast4}"
				currency: charge?.data?.currency?.toUpperCase()
				amount: wiz.framework.util.format.centsAsUSD(charge?.data?.amount)

			@server.root.api.receipt.database.createChargeReceipt req, res, receiptData, (req, res, receipt) =>
				receipt = receipt[0] if receipt instanceof Array
				console.log receipt

				# send slack notification
				@sendSlackNotification(data, user)
				res.send 200
	#}}}

	sendSlackNotification: (data, user) => #{{{
		msg = "[*Stripe*] "

		switch data.type
			when 'charge.succeeded'
				msg += "[*PAYMENT*] :moneybag:"
			else
				msg += "[*#{data.type.toUpperCase()}*]"

		# indent slack style
		msg += "\r>>>\r"

		# if present, append cypherpunk account email
		if user?.data?.email?
			msg += "\rCypherpunk account: `#{user.data.email}` (#{user.type})"

		# add invoice info
		msg += "\r"
		msg += "\r"

		# send to slack
		@server.root.slack.notify(msg)
	#}}}

	purchase: (req, res) => #{{{
		console.log req.body

		return res.send 400, 'missing parameters' unless (req.body?.token? and req.body?.plan?)
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.token is 'string'
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.plan is 'string'

		planType = cypherpunk.backend.pricing.getPricingPlanType req?.body?.plan
		return res.send 400, 'invalid plan' if not planType
		console.log planType

		stripePlanId = cypherpunk.backend.pricing.getStripePlanIdForReferralCode req?.body?.plan
		return res.send 400, 'invalid plan' if not stripePlanId
		console.log stripePlanId

		subscriptionRenewal = cypherpunk.backend.db.subscription.calculateRenewal stripePlanId
		return res.send 500, 'unable to calculate subscription period' if not subscriptionRenewal
		console.log subscriptionRenewal

		stripeArgs =
			source: req.body.token
			plan: stripePlanId
			email: req.body.email

		@Stripe.customers.create stripeArgs, (stripeError, stripeCustomerData) =>
			# handle error
			return @onError(req, res, stripeError) if stripeError or not stripeCustomerData?.id?

			console.log 'customer data from stripe'
			console.log stripeCustomerData

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
					accountID: user?.id
					provider: 'stripe'
					providerPlanID: stripeCustomerData?.subscriptions?.data?[0]?.plan?.id
					providerSubscriptionID: stripeCustomerData?.subscriptions?.data?[0].id
					currentPeriodStartTS: new Date()
					currentPeriodEndTS: subscriptionRenewal
					purchaseTS: new Date()
					renewalTS: subscriptionRenewal
					active: 'true'

				console.log 'subscription data'
				console.log subscriptionData

				# save transaction in db
				req.server.root.api.subscription.database.createElite req, res, subscriptionData, (req, res, subscription) =>
					# set user's active subscription to this one
					@onSuccessfulTransaction(req, res, subscription, req.session.account?.data?.stripeCustomerID)
	#}}}

	upgrade: (req, res) => #{{{
		# validate plan
		return res.send 400, 'missing parameters' unless req.body?.plan?
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.plan is 'string'

		planType = cypherpunk.backend.pricing.getPricingPlanType req?.body?.plan
		return res.send 400, 'invalid plan' if not planType
		console.log planType

		stripePlanId = cypherpunk.backend.pricing.getStripePlanIdForReferralCode req?.body?.plan
		return res.send 400, 'invalid plan' if not stripePlanId
		console.log stripePlanId

		subscriptionRenewal = cypherpunk.backend.db.subscription.calculateRenewal stripePlanId
		return res.send 500, 'unable to calculate subscription period' if not subscriptionRenewal
		console.log subscriptionRenewal

		# check to see if the user has a stripe account already
		if req.session.account?.data?.stripeCustomerID
			@upgradeExistingCustomer req, res, stripePlanId, planType, subscriptionRenewal
		else # if not yet a stripe customer, token is necessary
			return res.send 400, 'missing parameters' unless req.body?.token?
			return res.send 400, 'missing or invalid parameters' unless typeof req.body.token is 'string'
			@upgradeNewCustomer req, res, stripePlanId, planType, subscriptionRenewal

	#}}}
	upgradeExistingCustomer: (req, res, stripePlanId, planType, subscriptionRenewal) => #{{{
		# check to see if the user has a stripe account already
		stripeArgs =
			customer: req.session.account?.data?.stripeCustomerID
			plan: stripePlanId

		stripeArgs.source = req.body.token if req.body?.token?

		console.log 'stripeArgs'
		console.log stripeArgs

		@Stripe.subscriptions.create stripeArgs, (stripeError, stripeSubData) =>
			# handle error
			return @onError(req, res, stripeError) if stripeError

			console.log 'customer data from stripe'
			console.log stripeSubData

			# gather subscription data for insert() into db
			subscriptionData =
				provider: 'stripe'
				providerPlanID: stripeSubData?.plan?.id
				providerSubscriptionID: stripeSubData?.id
				currentPeriodStartTS: new Date()
				currentPeriodEndTS: subscriptionRenewal
				purchaseTS: new Date()
				renewalTS: subscriptionRenewal
				active: 'true'

			console.log 'subscription data'
			console.log subscriptionData

			# save transaction in db
			req.server.root.api.subscription.database.createElite req, res, subscriptionData, (req, res, subscription) =>
				# set user's active subscription to this one
				@onSuccessfulTransaction(req, res, subscription, req.session.account?.data?.stripeCustomerID)
	#}}}
	upgradeNewCustomer: (req, res, stripePlanId, planType, subscriptionRenewal) => #{{{
		# check to see if the user has a stripe account already
		stripeArgs =
			source: req.body.token
			plan: stripePlanId
			email: req.session?.account?.data?.email
#			metadata:
#				id: req.session?.account?.id

		console.log 'stripeArgs'
		console.log stripeArgs

		@Stripe.customers.create stripeArgs, (stripeError, stripeCustomerData) =>
			# handle error
			return @onError(req, res, stripeError) if stripeError or not stripeCustomerData?.id?

			console.log 'customer data from stripe'
			console.log stripeCustomerData

			# gather subscription data for insert() into db
			subscriptionData =
				provider: 'stripe'
				providerPlanID: stripeCustomerData?.subscriptions?.data?[0]?.plan?.id
				providerSubscriptionID: stripeCustomerData?.subscriptions?.data?[0].id
				currentPeriodStartTS: new Date()
				currentPeriodEndTS: subscriptionRenewal
				purchaseTS: new Date()
				renewalTS: subscriptionRenewal
				active: 'true'

			console.log 'subscription data'
			console.log subscriptionData

			# save transaction in db
			req.server.root.api.subscription.database.createElite req, res, subscriptionData, (req, res, subscription) =>
				# set user's active subscription to this one
				@onSuccessfulTransaction(req, res, subscription, stripeCustomerData?.id)
	#}}}

	onSuccessfulTransaction: (req, res, subscription, stripeCustomerID) => #{{{
		# prepare args
		upgradeArgs =
			stripeCustomerID: stripeCustomerID

		# pass updated db object to radius database method
		req.server.root.api.user.database.upgrade req, res, req.session.account.id, subscription.id, upgradeArgs, (req, res, user) =>

			# send purchase mail
			req.server.root.sendgrid.sendPurchaseMail user, (sendgridError) =>
				if sendgridError
					wiz.log.err "Unable to send email to #{user?.data?.email} due to sendgrid error"
					console.log sendgridError

			# create session for new account
			out = req.server.root.account.doUserLogin(req, res, user)
			res.send 200, out
	#}}}

# vim: foldmethod=marker wrap
