require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

require './_framework/thirdparty/amazon'

wiz.package 'cypherpunk.backend.api.v0.account.upgrade.amazon'

class cypherpunk.backend.api.v0.account.upgrade.amazon extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.expired
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.base
	nav: false

	handler: (req, res) =>
		req.server.root.amazon.upgrade(req, res)

# vim: foldmethod=marker wrap
