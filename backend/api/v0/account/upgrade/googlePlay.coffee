require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

wiz.package 'cypherpunk.backend.api.v0.account.upgrade'

class cypherpunk.backend.api.v0.account.upgrade.googlePlay extends cypherpunk.backend.base
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

				out = @parent.parent.accountinfo(req)
				res.send 200, out
	#}}}

# vim: foldmethod=marker wrap
