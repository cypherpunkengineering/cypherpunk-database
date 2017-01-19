require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

require './amazon'
require './stripe'

wiz.package 'cypherpunk.backend.api.v0.account.purchase'

class cypherpunk.backend.api.v0.account.purchase.resource extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.free
	mask: cypherpunk.backend.server.power.mask.auth
	nav: false

	load: () =>
		# inherit
		super()

		# public account creation api
		@routeAdd new cypherpunk.backend.api.v0.account.purchase.stripe(@server, this, 'stripe', 'POST')
		@routeAdd new cypherpunk.backend.api.v0.account.purchase.amazon(@server, this, 'amazon', 'POST')

# vim: foldmethod=marker wrap
