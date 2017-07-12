require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'

wiz.package 'cypherpunk.backend.api.v0.account.change.password'

class cypherpunk.backend.api.v0.account.change.password extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	handler: (req, res) =>
		return res.send 400, 'missing old password' unless req.body?.passwordOld?
		return res.send 400, 'missing new password' unless req.body?.passwordNew?
		return res.send 400, 'invalid old password' unless wiz.framework.util.strval.ascii_valid(req.body.passwordOld)
		return res.send 400, 'invalid new password' unless wiz.framework.util.strval.ascii_valid(req.body.passwordNew)
		@server.root.api.user.database.updateCurrentUserPassword(req, res, req.body.passwordOld, req.body.passwordNew)

# vim: foldmethod=marker wrap
