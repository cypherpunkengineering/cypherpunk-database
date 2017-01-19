require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

require './_framework/thirdparty/stripe'
require './_framework/thirdparty/sendgrid'

wiz.package 'cypherpunk.backend.api.v0.account.upgrade.stripe'

class cypherpunk.backend.api.v0.account.upgrade.stripe extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.base
	nav: false

	handler: (req, res) =>
		req.server.root.stripe.upgrade(req, res)

# vim: foldmethod=marker wrap
