require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

require './_framework/thirdparty/amazon'

util = require 'util'

wiz.package 'cypherpunk.backend.api.v0.account.purchase.amazon'

class cypherpunk.backend.api.v0.account.purchase.amazon extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	handler: (req, res) =>
		console.log req.body

		# validate params
		return res.send 400, 'missing parameters' unless req.body?.email?
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.email is 'string'

		return res.send 400, 'missing parameters' unless req.body?.AmazonBillingAgreementId?
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.AmazonBillingAgreementId is 'string'

		# nuke existing session if any
		wiz.framework.http.account.session.logout(req, res)

		# check if account already exists on given email address
		@server.root.api.user.database.findOneByEmail req, res, req.body.email, (req, res, user) =>

			# if so, return error
			return res.send 409, 'Email already registered' if user isnt null

			# prepare args for amazon API call
			amazonArgs =
				AmazonBillingAgreementId: req.body.AmazonBillingAgreementId
				plan: req.body.plan

			# get billing agreement details
			req.server.root.amazon.confirmBillingAgreement req, res, amazonArgs, (res2) =>
				amazonResponse = res2.body
				console.log 'print response'
				console.log(util.inspect(amazonResponse, false, null))
				res.send 200

# vim: foldmethod=marker wrap
