require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

require './_framework/thirdparty/amazon'

wiz.package 'cypherpunk.backend.api.v0.account.upgrade.amazon'

class cypherpunk.backend.api.v0.account.upgrade.amazon extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.base
	nav: false

	handler: (req, res) =>
		# validate params
		return res.send 400, 'missing parameters' unless (req.body?.amazonBillingAgreementId?)
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.amazonBillingAgreementId is 'string'

		# prepare args for amazon API call
		amazonArgs =
			AmazonBillingAgreementId: req.body.amazonBillingAgreementId

		# get billing agreement details
		req.server.root.amazon.getBillingAgreementDetails(req, res, args)

# vim: foldmethod=marker wrap
