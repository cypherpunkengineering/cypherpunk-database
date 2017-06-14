require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

wiz.package 'cypherpunk.backend.api.v0.ipn.bitpay'

class cypherpunk.backend.api.v0.ipn.bitpay extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	middleware: wiz.framework.http.account.session.refresh
	nav: false

	handler: (req, res) =>
		@server.root.bitpay.ipn(req, res)

# vim: foldmethod=marker wrap
