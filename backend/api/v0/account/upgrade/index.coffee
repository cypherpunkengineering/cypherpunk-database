# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'
require './_framework/thirdparty/stripe'

wiz.package 'cypherpunk.backend.api.v0.account.upgrade'

class cypherpunk.backend.api.v0.account.upgrade.googlePlay extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.free
	mask: cypherpunk.backend.server.power.mask.auth
	handler: (req, res) => #{{{

		console.log req.body

		return res.send 400, 'missing parameters' unless (req.body?.planId? and req.body?.transactionDataObject?)
		return res.send 400, 'invalid plan' unless wiz.framework.util.strval.validate('asciiNoSpace', req.body.planId)
		#return res.send 400, 'invalid transactionObjectData' unless typeof req.body.transactionDataObject is 'object'

		@server.root.api.user.database.upgrade req, res, req.session.account.id, (req2, res2, result) =>
			@server.root.sendUpgradeMail result, (sendgridError) =>
				if sendgridError
					wiz.log.err "Unable to send email to #{user.data.email} due to sendgrid error"
					console.log sendgridError
					return

			res.send 200
	#}}}

class cypherpunk.backend.api.v0.account.upgrade.resource extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	load: () =>
		# inherit
		super()

		# public account creation api
		@routeAdd new cypherpunk.backend.api.v0.account.upgrade.googlePlay(@server, this, 'GooglePlay', 'POST')

# vim: foldmethod=marker wrap
