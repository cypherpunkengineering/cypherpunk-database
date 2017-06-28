require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../../db/user'

require './receipts'

wiz.package 'cypherpunk.backend.api.v0.billing'

class cypherpunk.backend.api.v0.billing.module extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.friend
	mask: cypherpunk.backend.server.power.mask.auth
	nav: false

	load: () =>
		super()
		@routeAdd new cypherpunk.backend.api.v0.billing.receipts(@server, this, 'receipts')

# vim: foldmethod=marker wrap
