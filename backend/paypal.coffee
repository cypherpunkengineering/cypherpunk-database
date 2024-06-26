require './_framework'
require './_framework/thirdparty/paypal'

wiz.package 'cypherpunk.backend.paypal'

class cypherpunk.backend.paypal extends wiz.framework.thirdparty.paypal

	ipn: (req, res) => #{{{
		# get data from request body
		data = req.body

		# parse "custom" field as json
		try
			data.custom = JSON.parse(req.body.custom)
			data.cypherpunk_account_id = data.custom.id
			data.cypherpunk_plan_type = cypherpunk.backend.pricing.getPricingPlanType(data.custom.plan)
		catch e
			data.custom = {}

		switch data.txn_type
			when 'subscr_signup'
				@onSubscriptionSignup(req, res, data)
			when 'subscr_cancel'
				@onSubscriptionCancel(req, res, data)
			when 'subscr_payment'
				@onSubscriptionPayment(req, res, data)
			when 'subscr_eot'
				@sendSlackNotification(data)
				res.send 200
			else
				# send to billing channel on slack
				@sendSlackNotification(data)
				res.send 500, 'Unknown PayPal IPN type!'
		#}}}

	sendSlackNotification: (data, user) => #{{{
		msg = "[*PayPal*] "

		switch data.txn_type
			when 'subscr_signup'
				msg += "[*SUBSCRIPTION*] :grinning:"
			when 'subscr_payment'
				msg += "[*PAYMENT*] :moneybag:"
			when 'subscr_cancel'
				msg += "[*CANCEL*] :cry:"
			else
				msg += "[*#{data.txn_type}*]"

		# indent slack style
		msg += "\r>>>\r"

		# append paypal payer email
		msg += "\rPayPal account: `#{data.payer_email}` :#{data.residence_country}: (#{data.payer_status})"

		# if present, append cypherpunk account email
		if user?.data?.email?
			msg += "\rCypherpunk account: `#{user.data.email}` (#{user.type})"

		switch data.txn_type
			when 'subscr_signup'
				msg += "\rPayPal subscription `#{data.subscr_id}` to plan `#{data.item_number}`"
				msg += "\rAutomatically renews every `#{data.period3}` for `#{data.mc_amount3} #{data.mc_currency}` starting on #{data.subscr_date}"
			when 'subscr_payment'
				msg += "\rPayPal Payment `#{data.mc_gross}` received for subscription `#{data.subscr_id}` to plan `#{data.item_number}`!"
			when 'subscr_cancel'
				msg += "\rCancelled their PayPal subscription `#{data.subscr_id}` to plan `#{data.item_number}`"

			else
				msg += "\rfrom paypal account `#{data.payer_email}` (#{data.payer_status})" if data?.txn_type?
				msg += "\rfor subscription `#{data.subscr_id}`" if data?.subscr_id?
				msg += "\rfor cypherpunk plan `#{data.item_number}`" if data?.item_number?
				msg += "\rperiod `#{data.period3}`" if data?.period3?
				msg += "\ramount `#{data.mc_amount3} #{data.mc_currency}`" if data?.mc_amount3?

		# send to slack
		@server.root.slack.notify(msg)
	#}}}

	onSubscriptionSignup: (req, res, data) => #{{{
#{{{ sample data
#
# { amount3: '11.95',
#   btn_id: '3666711',
#   business: 'paypaltest-facilitator@cypherpunk.com',
#   charset: 'windows-1252',
#   custom: {
#     id: "4XUYJWGG4LHKMHCLKL7OTIWP7O4UVBJCGO2PIPMXQVV2NZNO2UF",
#     plan: "monthly"
#   },
#   first_name: 'test',
#   ipn_track_id: '64ac54315ff5d',
#   item_name: 'Premium Access to Cypherpunk Privacy',
#   item_number: 'monthly1195',
#   last_name: 'buyer',
#   mc_amount3: '11.95',
#   mc_currency: 'USD',
#   notify_version: '3.8',
#   payer_email: 'paypaltest-buyer@cypherpunk.com',
#   payer_id: 'SR5VZMWJRMJLL',
#   payer_status: 'verified',
#   period3: '1 M',
#   reattempt: '1',
#   receiver_email: 'paypaltest-facilitator@cypherpunk.com',
#   recurring: '1',
#   residence_country: 'US',
#   subscr_date: '03:15:15 Jun 12, 2017 PDT',
#   subscr_id: 'I-ETCPA4FW0WN4',
#   test_ipn: '1',
#   txn_type: 'subscr_signup',
#   verify_sign: 'AWYxjS6LEFCeGqJDu35ZiF0NsD2FAHtXH7K7Pn6SOYFMwCDrrBLioo9K' }
#}}}

		# validate required arguments exist
		return res.send 400, 'missing or invalid cypherpunk account id' unless typeof data.cypherpunk_account_id is 'string'
		return res.send 400, 'missing or invalid cypherpunk plan type' unless typeof data.cypherpunk_plan_type is 'string'

		# validate plan type is valid
		planType = cypherpunk.backend.pricing.getPricingPlanType(data.cypherpunk_plan_type)
		return res.send 400, 'invalid cypherpunk plan type' unless typeof planType is 'string'

		# get plan data and confirm price matches
		planID = data.item_number
		plan = cypherpunk.backend.pricing.getPlanByTypeAndID(planType, planID)
		return res.send 400, 'unknown paypal item number' unless plan?
		return res.send 400, "plan price #{plan.price} doesnt match paypal invoice amount #{data.mc_amount3}" unless +plan.price == +data.mc_amount3

		# lookup account object by given account id
		@server.root.api.user.database.findOneByID req, res, data.cypherpunk_account_id, (req, res, user) =>

			# if not found, return error
			return res.send 404, 'Cypherpunk ID not found!' if not user?

			# calculate renewal date
			subscriptionRenewal = cypherpunk.backend.db.subscription.calculateRenewal planID
			return res.send 500, 'unable to calculate subscription period' if not subscriptionRenewal?

			# gather subscription data for insert() into db
			subscriptionData =
				provider: 'paypal'
				providerPlanID: planID
				providerSubscriptionID: data.subscr_id
				currentPeriodStartTS: new Date()
				currentPeriodEndTS: subscriptionRenewal
				purchaseTS: new Date()
				renewalTS: subscriptionRenewal
				active: 'true'

			console.log 'subscription data'
			console.log subscriptionData

			# create subscription object in db
			@server.root.api.subscription.database.createElite req, res, subscriptionData, (req, res, subscription) =>

				# prepare args
				upgradeArgs =
					paypalSubscriptionID: data.subscr_id

				# set user's active subscription to this new one, pass updated db object to radius database method
				req.server.root.api.user.database.upgrade req, res, user.id, subscription.id, upgradeArgs, (req, res, user) =>

					# send purchase mail
					req.server.root.sendgrid.sendPurchaseMail user, (sendgridError) =>
						if sendgridError
							wiz.log.err "Unable to send email to #{user?.data?.email} due to sendgrid error"
							console.log sendgridError

					# send slack notification
					@sendSlackNotification(data, user)

					# finally return OK
					res.send 200
	#}}}
	onSubscriptionPayment: (req, res, data) => #{{{
# {{{ sample data
#
# { btn_id: '3666711',
#   business: 'paypaltest-facilitator@cypherpunk.com',
#   charset: 'windows-1252',
#   custom: {
#     id: "4XUYJWGG4LHKMHCLKL7OTIWP7O4UVBJCGO2PIPMXQVV2NZNO2UF",
#     plan: "monthly"
#   },
#   first_name: 'test',
#   ipn_track_id: '64ac54315ff5d',
#   item_name: 'Premium Access to Cypherpunk Privacy',
#   item_number: 'monthly1195',
#   last_name: 'buyer',
#   mc_currency: 'USD',
#   mc_fee: '0.65',
#   mc_gross: '11.95',
#   notify_version: '3.8',
#   payer_email: 'paypaltest-buyer@cypherpunk.com',
#   payer_id: 'SR5VZMWJRMJLL',
#   payer_status: 'verified',
#   payment_date: '03:15:18 Jun 12, 2017 PDT',
#   payment_status: 'Completed',
#   payment_type: 'instant',
#   receiver_email: 'paypaltest-facilitator@cypherpunk.com',
#   receiver_id: 'KXB398KPF7VMW',
#   residence_country: 'US',
#   subscr_id: 'I-ETCPA4FW0WN4',
#   test_ipn: '1',
#   txn_id: '8G714942TJ100635R',
#   txn_type: 'subscr_payment',
#   verify_sign: 'AE.pCRu8dAgEChKtiAO8IAX666.2A0L3dEvMwyN3KOTNOlAAKFzs6iin' }
#}}}
		# lookup account object by given account id
		@server.root.api.user.database.findOneByID req, res, data.cypherpunk_account_id, (req, res, user) =>

			# if not found, return error
			return res.send 404, 'Cypherpunk ID not found!' if not user?

			@server.root.api.charge.database.saveFromIPN req, res, 'paypal', data, (req, res, charge) =>
				charge = charge[0] if charge instanceof Array
				console.log charge

				#TODO: check payment_status == "Completed"

				receiptData =
					accountID: user?.id
					transactionID: charge?.data?.txn_id
					paymentTS: new Date(Date.parse(charge?.data?.payment_date))
					description: "Cypherpunk Privacy Elite subscription"
					method: "PayPal #{charge?.data?.txn_id}"
					currency: charge?.data?.mc_currency
					amount: charge?.data?.mc_gross

				@server.root.api.receipt.database.createChargeReceipt req, res, receiptData, (req, res, receipt) =>
					receipt = receipt[0] if receipt instanceof Array
					console.log receipt

					# send slack notification
					@sendSlackNotification(data, user)
					res.send 200
	#}}}
	onSubscriptionCancel: (req, res, data) => #{{{
# {{{ sample data
#
# { amount3: '69.00',
#   btn_id: '3666714',
#   business: 'paypaltest-facilitator@cypherpunk.com',
#   charset: 'windows-1252',
#   custom: {
#     id: "4XUYJWGG4LHKMHCLKL7OTIWP7O4UVBJCGO2PIPMXQVV2NZNO2UF",
#     plan: "annually"
#   },
#   first_name: 'test',
#   ipn_track_id: '4e6a54fc31199',
#   item_name: 'Premium Access to Cypherpunk Privacy',
#   item_number: 'annually6900',
#   last_name: 'buyer',
#   mc_amount3: '69.00',
#   mc_currency: 'USD',
#   notify_version: '3.8',
#   payer_email: 'paypaltest-buyer@cypherpunk.com',
#   payer_id: 'SR5VZMWJRMJLL',
#   payer_status: 'verified',
#   period3: '12 M',
#   reattempt: '1',
#   receiver_email: 'paypaltest-facilitator@cypherpunk.com',
#   recurring: '1',
#   residence_country: 'US',
#   subscr_date: '02:50:12 Jun 12, 2017 PDT',
#   subscr_id: 'I-DS5XK8YRVKKV',
#   test_ipn: '1',
#   txn_type: 'subscr_cancel',
#   verify_sign: 'AiPC9BjkCyDFQXbSkoZcgqH3hpacA1Z3qP3.5UcNUy.BwUI1YJPeGDyD' }
#}}}
		# lookup account object by given account id
		@server.root.api.user.database.findOneByID req, res, data.cypherpunk_account_id, (req, res, user) =>

			# if not found, return error
			return res.send 404, 'Cypherpunk ID not found!' if not user?

			# send slack notification
			@sendSlackNotification(data, user)

			res.send 200
	#}}}

# vim: foldmethod=marker wrap
