require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

require './googlePlay'

wiz.package 'cypherpunk.backend.api.v0.account.upgrade'

class cypherpunk.backend.api.v0.account.upgrade.resource extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.free
	mask: cypherpunk.backend.server.power.mask.auth
	nav: false

	load: () =>
		# inherit
		super()

		# public account creation api
		@routeAdd new cypherpunk.backend.api.v0.account.upgrade.googlePlay(@server, this, 'GooglePlay', 'POST')
		# @routeAdd new cypherpunk.backend.api.v0.account.upgrade.stripe(@server, this, 'stripe', 'POST')

# vim: foldmethod=marker wrap
