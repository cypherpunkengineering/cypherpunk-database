require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'

wiz.package 'cypherpunk.backend.api.v0.billing.receipts'

class cypherpunk.backend.api.v0.billing.receipts extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.expired
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.base

	handler: (req, res) =>
		@server.root.api.receipt.database.getReceiptsForCurrentUser(req, res)

# vim: foldmethod=marker wrap
