# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'
require './_framework/thirdparty/stripe'

wiz.package 'cypherpunk.backend.api.v0.account.confirm'

class cypherpunk.backend.api.v0.account.confirm.email extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	handler: (req, res) => # public account email verification api
		return res.send 400, 'missing parameters' unless (req.body?.accountId? and req.body?.confirmationToken?)
		return res.send 400, 'missing or invalid accountId' unless wiz.framework.util.strval.alphanumeric_valid(req.body.accountId)
		return res.send 400, 'missing or invalid confirmationToken' unless wiz.framework.util.strval.alphanumeric_valid(req.body.confirmationToken)

		@server.root.api.user.database.confirm req, res, req.body.accountId, req.body.confirmationToken, (req, res, user) =>
			# start new session for confirmed user
			out = @parent.parent.doUserLogin(req, res, user)
			res.send 200, out

class cypherpunk.backend.api.v0.account.confirm.emailChange extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	handler: (req, res) => # public account emailChange verification api
		return res.send 400, 'missing parameters' unless (req.body?.accountId? and req.body?.confirmationToken?)
		return res.send 400, 'missing or invalid accountId' unless wiz.framework.util.strval.alphanumeric_valid(req.body.accountId)
		return res.send 400, 'missing or invalid confirmationToken' unless wiz.framework.util.strval.alphanumeric_valid(req.body.confirmationToken)

		@server.root.api.user.database.confirmChange req, res, req.body.accountId, req.body.confirmationToken, (req, res, user) =>
			# start new session for confirmed user
			out = @parent.parent.doUserLogin(req, res, user)
			res.send 200, out

class cypherpunk.backend.api.v0.account.confirm.resource extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	load: () =>
		# inherit
		super()

		# public account creation api
		@routeAdd new cypherpunk.backend.api.v0.account.confirm.email(@server, this, 'email', 'POST')
		@routeAdd new cypherpunk.backend.api.v0.account.confirm.emailChange(@server, this, 'emailChange', 'POST')

# vim: foldmethod=marker wrap
