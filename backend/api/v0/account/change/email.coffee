require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'

wiz.package 'cypherpunk.backend.api.v0.account.change.email'

class cypherpunk.backend.api.v0.account.change.email extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	handler: (req, res) =>
		return res.send 400, 'missing email' unless req.body?.email?
		return res.send 400, 'missing password' unless req.body?.password?
		return res.send 400, 'invalid email' unless wiz.framework.util.strval.email_valid(req.body.email)
		return res.send 400, 'invalid email' unless wiz.framework.util.strval.ascii_valid(req.body.password)
		@server.root.api.user.database.updateCurrentUserEmail(req, res, req.body.password, req.body.email)

# vim: foldmethod=marker wrap
