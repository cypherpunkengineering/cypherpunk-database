require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

require './_framework/thirdparty/amazon'

wiz.package 'cypherpunk.backend.api.v0.account.purchase.amazon'

class cypherpunk.backend.api.v0.account.purchase.amazon extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	handler: (req, res) =>
		console.log req.body
		# validate params
		return res.send 400, 'missing parameters' unless (req.body?.AmazonBillingAgreementId?)
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

			# get billing agreement details
			req.server.root.amazon.getBillingAgreementDetails(req, res, amazonArgs)

# vim: foldmethod=marker wrap
