# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'
require './_framework/thirdparty/stripe'

wiz.package 'cypherpunk.backend.api.v0.account.confirm'

class cypherpunk.backend.api.v0.account.confirm.resource extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	# public account email verification api
	catchall: (req, res, accountID) => #{{{
		return res.send 400, 'missing parameters' unless (accountID? and req.params?.confirmationToken?)
		return res.send 400, 'missing or invalid account ID' unless wiz.framework.util.strval.alphanumeric_valid(accountID)

		wiz.log.debug 'accountID is '+accountID
		wiz.log.debug 'confirmationToken is '+req.params.confirmationToken

		return res.send 400 unless accountID?
		@server.root.api.user.database.findOneByID req, res, accountID, (user) =>
			return res.send 404 unless user?
			return res.send 401, 'invalid token' if req.params.confirmationToken != user.confirmationToken
			@server.root.api.user.database.updateCustomDataByID req, res, accountID, @server.root.api.user.database.schema.confirmedKey, true, (result) =>
				res.send 500, 'Unable to confirm account' if not result?

				# start session
				user.confirmed = true
				out = @server.root.account.authenticate.password.doUserLogin(req, res, user)
				res.send 200, out
	#}}}

# vim: foldmethod=marker wrap
