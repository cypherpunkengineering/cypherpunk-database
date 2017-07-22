# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

wiz.package 'cypherpunk.backend.api.v0.account.recover'

class cypherpunk.backend.api.v0.account.recover.email extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	handler: (req, res) => # public account recovery by email api
		return res.send 400, 'missing parameters' unless req.body?.email?
		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.ascii_valid(req.body.email)
		@server.root.api.user.database.recoverEmail(req, res, req.body.email)

class cypherpunk.backend.api.v0.account.recover.reset extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	handler: (req, res) => # public account reset by token api
		return res.send 400, 'missing or invalid accountId' unless req.body?.accountId? and wiz.framework.util.strval.alphanumeric_valid(req.body.accountId)
		return res.send 400, 'missing or invalid token' unless req.body?.token? and wiz.framework.util.strval.alphanumeric_valid(req.body.token)
		return res.send 400, 'missing or invalid password' unless req.body?.password? and wiz.framework.util.strval.ascii_valid(req.body.password)

		@server.root.api.user.database.recoverReset req, res, req.body.accountId, req.body.token, req.body.password, (req, res, user) =>
			# start new session for recovered user
			out = @parent.parent.doUserLogin(req, res, user)
			res.send 200, out

class cypherpunk.backend.api.v0.account.recover.resource extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	load: () =>
		# inherit
		super()

		# public account creation api
		@routeAdd new cypherpunk.backend.api.v0.account.recover.email(@server, this, 'email', 'POST')
		@routeAdd new cypherpunk.backend.api.v0.account.recover.reset(@server, this, 'reset', 'POST')

# vim: foldmethod=marker wrap
