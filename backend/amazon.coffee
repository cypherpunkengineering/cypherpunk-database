require './_framework'

util = require 'util'

crypto = require 'crypto'
BigInteger = require './_framework/crypto/jsbn'

wiz.package 'cypherpunk.backend.amazon'

class cypherpunk.backend.amazon extends wiz.framework.thirdparty.amazon
	purchase: (req, res, amazonBillingAgreementId) => #{{{
		# validate params
		return res.send 400, 'missing parameters' unless req.body?.AmazonBillingAgreementId?
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.AmazonBillingAgreementId is 'string'

		subscriptionType = cypherpunk.backend.db.subscription.calculateType req?.body?.plan
		subscriptionRenewal = cypherpunk.backend.db.subscription.calculateRenewal req?.body?.plan
		subscriptionPrice = cypherpunk.backend.db.subscription.calculatePrice req?.body?.plan

		return res.send 400, 'invalid plan' unless (subscriptionRenewal and subscriptionType and subscriptionPrice)

		# prepare args for amazon API call
		confirmArgs =
			AmazonBillingAgreementId: req.body.AmazonBillingAgreementId
			plan: req.body.plan

		@confirmBillingAgreement req, res, confirmArgs, (amazonResponse) =>
			# TODO check for errors

			console.log(util.inspect(amazonResponse, false, null))

			userData =
				confirmed: true
				amazonBillingAgreementID: req.body.AmazonBillingAgreementId

			req.server.root.api.user.database.signup req, res, userData, (req2, res2, result) =>
				# get 0th result
				if result instanceof Array then user = result[0] else user = result
				console.log user

				# get some random bits
				randomBytes = new BigInteger(crypto.randomBytes(16))

				# prepare arguments for authorization API call
				authorizeArgs =
					AmazonBillingAgreementId: user?.data?.amazonBillingAgreementID
					currency: "USD"
					price: subscriptionPrice
					authorizationReference: wiz.framework.crypto.convert.biToBase32(randomBytes)
					userId: user?.id

				# call AuthorizeOnBillingAgreement
				@authorizeOnBillingAgreement req, res, authorizeArgs, (result) =>
					console.log "result is "+result
					return res.send 402, result if result isnt "Closed"

					# create session for new account
					out = req.server.root.account.doUserLogin(req, res, user)
					res.send 200, out
	#}}}
	upgrade: (req, res) => #{{{
		# validate params
		return res.send 400, 'missing parameters' unless req.body?.AmazonBillingAgreementId?
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.AmazonBillingAgreementId is 'string'

		subscriptionType = cypherpunk.backend.db.subscription.calculateType req?.body?.plan
		subscriptionRenewal = cypherpunk.backend.db.subscription.calculateRenewal req?.body?.plan
		subscriptionPrice = cypherpunk.backend.db.subscription.calculatePrice req?.body?.plan

		return res.send 400, 'invalid plan' unless (subscriptionRenewal and subscriptionType and subscriptionPrice)

		# prepare args for amazon API call
		confirmArgs =
			AmazonBillingAgreementId: req.body.AmazonBillingAgreementId
			plan: req.body.plan

		@confirmBillingAgreement req, res, confirmArgs, (amazonResponse) =>
			# TODO check for errors

			console.log(util.inspect(amazonResponse, false, null))

			# get some random bits
			randomBytes = new BigInteger(crypto.randomBytes(16))

			# prepare arguments for authorization API call
			authorizeArgs =
				AmazonBillingAgreementId: req.body.AmazonBillingAgreementId
				currency: "USD"
				price: subscriptionPrice
				authorizationReference: wiz.framework.crypto.convert.biToBase32(randomBytes)
				userId: user?.id

			# call AuthorizeOnBillingAgreement
			@authorizeOnBillingAgreement req, res, authorizeArgs, (result) =>
				console.log "result is "+result
				return res.send 402, result if result isnt "Closed"

				# gather subscription data for insert() into db
				subscriptionData =
					provider: 'amazon'
					providerPlanID: req.body.plan
					providerSubscriptionID: user?.data?.amazonBillingAgreementID
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
					@onSuccessfulTransaction(req, res, subscription, user?.data?.amazonBillingAgreementID)
	#}}}
	onSuccessfulTransaction: (req, res, subscription, amazonBillingAgreementID) => #{{{
		# prepare args
		upgradeArgs =
			amazonBillingAgreementID: amazonBillingAgreementID

		# pass updated db object to radius database method
		req.server.root.api.user.database.upgrade req, res, req.session.account.id, subscription.id, upgradeArgs, (req, res, user) =>

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
