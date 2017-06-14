require './_framework'
require './_framework/thirdparty/bitpay'

wiz.package 'cypherpunk.backend.bitpay'

class cypherpunk.backend.bitpay extends wiz.framework.thirdparty.bitpay

	ipn: (req, res) => #{{{
		# get data from request body
		data = req.body

		# parse "custom" field as json
		try
			data.posData = JSON.parse(req.body.posData)
			data.cypherpunk_account_id = data.posData.id
			data.cypherpunk_plan_type = cypherpunk.backend.pricing.getPricingPlanType(data.posData.plan)
		catch e
			data.custom = {}

		switch data.action
			when 'invoiceStatus'
				if data.status is 'confirmed'
					@onInvoicePaid(req, res, data)
				else
					@sendSlackNotification(data)
			else
				# send to billing channel on slack
				@sendSlackNotification(data)
				res.send 500, 'Unknown BitPay IPN type!'
	#}}}

	sendSlackNotification: (data) => #{{{
		msg = "[*BitPay*] "

		switch data.action
			when 'invoiceStatus'
				if data.status is 'confirmed'
					msg += "[*PAYMENT*] :moneybag:"
				else
					msg += "[*INVOICE*] #{data.status.toUpperCase()}*]"
			else
				msg += "[*#{data.action?.toUpperCase()}*]"

		# indent slack style
		msg += "\r>>>\r"

		# if present, append cypherpunk account email
		if data.user?.data?.email?
			msg += "\rCypherpunk account: `#{data.user.data.email}` (#{data.user.type})"

		# add invoice info
		msg += "\rBitPay invoice `#{data?.invoice_id}` is #{data?.status}"
		msg += "\rAmount: &#x0e3f; #{data?.btcPaid} BTC -> #{data?.amount} USD"

		# send to slack
		@server.root.slack.notify(msg)
	#}}}

	onInvoicePaid: (req, res, data) => #{{{

#{{{ sample data
# { invoice_id: 'Ao5BLYJEZfhQTdqiXVC2Ps',
#   status: 'confirmed',
#   exceptionStatus: false,
#   amount: '11.95',
#   rate: '2763.2',
#   action: 'invoiceStatus',
#   btcPaid: '0.004325',
#   currency: 'USD',
#   posData: '{"id":"PB3PONXQMUN6QDMBYOZ5DD337357CWXY64O3ZE4DBXRJRZ3ZGB5","plan":"annually"}' }
#}}}
		# validate required arguments exist
		return res.send 400, 'missing or invalid cypherpunk account id' unless typeof data.cypherpunk_account_id is 'string'
		return res.send 400, 'missing or invalid cypherpunk plan type' unless typeof data.cypherpunk_plan_type is 'string'

		# validate plan type is valid
		planType = cypherpunk.backend.pricing.getPricingPlanType(data.cypherpunk_plan_type)
		return res.send 400, 'invalid cypherpunk plan type' unless typeof planType is 'string'

		# get plan data and confirm price matches TODO: lookup referral code here instead of using default
		planID = cypherpunk.backend.pricing.defaultPlanId[data.cypherpunk_plan_type]
		plan = cypherpunk.backend.pricing.getPlanByTypeAndID(planType, planID)
		return res.send 400, "plan price #{plan.price} doesnt match bitpay invoice amount #{data.amount}" unless +plan.price == +data.amount

		@server.root.api.charge.database.saveFromIPN req, res, 'bitpay', data, (req, res, chargeObject) =>
			#console.log chargeObject

			# lookup account object by given account id
			@server.root.api.user.database.findOneByID req, res, data.cypherpunk_account_id, (req, res, user) =>

				# if not found, return error
				return res.send 404, 'Cypherpunk ID not found!' if not user?

				# calculate renewal date
				subscriptionRenewal = cypherpunk.backend.db.subscription.calculateRenewal planID
				return res.send 500, 'unable to calculate subscription period' if not subscriptionRenewal
				console.log subscriptionRenewal

				# gather subscription data for insert() into db
				subscriptionData =
					provider: 'bitpay'
					providerPlanID: planID
					providerSubscriptionID: data.invoice_id
					currentPeriodStartTS: new Date().toISOString()
					currentPeriodEndTS: subscriptionRenewal
					purchaseTS: new Date().toISOString()
					renewalTS: subscriptionRenewal
					active: 'true'

				console.log 'subscription data'
				console.log subscriptionData

				# create subscription object in db
				@server.root.api.subscription.database.insert req, res, planType, subscriptionData, (req, res, subscription) =>

					# prepare args
					upgradeArgs =
						bitpayInvoiceID: data.invoice_id

					# set user's active subscription to this new one, pass updated db object to radius database method
					req.server.root.api.user.database.upgrade req, res, user.id, subscription.id, upgradeArgs, (req, res, user) =>

						# send purchase mail
						req.server.root.sendgrid.sendPurchaseMail user, (sendgridError) =>
							if sendgridError
								wiz.log.err "Unable to send email to #{user?.data?.email} due to sendgrid error"
								console.log sendgridError

						# send slack notification
						data.user = user
						@sendSlackNotification(data)

						# finally return OK
						res.send 200
	#}}}

# vim: foldmethod=marker wrap
