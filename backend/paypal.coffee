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
			data.cypherpunk_plan_type = data.custom.plan
		catch e
			data.custom = {}

		# send to billing channel on slack
		@sendSlackNotification(data)

		switch data.txn_type
			when 'subscr_signup'
				@onSubscriptionSignup(req, res, data)
			when 'subscr_cancel'
				@onSubscriptionCancel(req, res, data)
			when 'subscr_payment'
				@onSubscriptionPayment(req, res, data)
			else
				wiz.log.err 'Unknown Paypal IPN type!'
		#}}}

	sendSlackNotification: (data) => #{{{
		msg = ""
		msg += "[TEST]" if wiz.style is 'DEV'
		msg += " PayPal IPN: "
		msg += " *#{data.txn_type}*\n" if data?.txn_type?
		msg += ">>>\n"
		msg += "paypal customer: `#{data.payer_email}` (#{data.payer_status})\n" if data?.txn_type?
		msg += "subscription id: `#{data.subscr_id}`\n" if data?.subscr_id?
		msg += "plan: `#{data.item_number}`\n" if data?.item_number?
		msg += "period: `#{data.period3}`\n" if data?.period3?
		msg += "amount: `#{data.mc_amount3} #{data.mc_currency}`\n" if data?.mc_amount3?
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

		return res.send 200

		# validate plan
		return res.send 400, 'missing parameters' unless req.body?.plan?
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.plan is 'string'

		subscriptionPlanFreq = cypherpunk.backend.pricing.getPlanFreqForPlan req?.body?.plan
		return res.send 400, 'invalid plan' if not subscriptionPlanFreq
		console.log subscriptionPlanFreq

		stripePlanId = cypherpunk.backend.pricing.getStripePlanIdForReferralCode req?.body?.plan
		return res.send 400, 'invalid plan' if not stripePlanId
		console.log stripePlanId

		subscriptionRenewal = cypherpunk.backend.db.subscription.calculateRenewal stripePlanId
		return res.send 500, 'unable to calculate subscription period' if not subscriptionRenewal
		console.log subscriptionRenewal

		# check to see if the user has a stripe account already
		if req.session.account?.data?.stripeCustomerID
			@upgradeExistingCustomer req, res, subscriptionPlanFreq, subscriptionRenewal
		else # if not yet a stripe customer, token is necessary
			return res.send 400, 'missing parameters' unless req.body?.token?
			return res.send 400, 'missing or invalid parameters' unless typeof req.body.token is 'string'
			@upgradeNewCustomer req, res, subscriptionPlanFreq, subscriptionRenewal

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
		@server.root.api.charge.database.saveFromPayPalIPN req, res, data, (req, res, chargeObject) =>
			console.log chargeObject
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
		res.send 200
	#}}}

# vim: foldmethod=marker wrap
