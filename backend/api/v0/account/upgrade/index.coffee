require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

require './amazon'
require './apple'
require './google'
require './stripe'

wiz.package 'cypherpunk.backend.api.v0.account.upgrade'

class cypherpunk.backend.api.v0.account.upgrade.resource extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.expired
	mask: cypherpunk.backend.server.power.mask.auth
	nav: false

	load: () =>
		# inherit
		super()

		# for web frontend
		@routeAdd new cypherpunk.backend.api.v0.account.upgrade.amazon(@server, this, 'amazon', 'POST')
		@routeAdd new cypherpunk.backend.api.v0.account.upgrade.stripe(@server, this, 'stripe', 'POST')

		# for mobile apps
		@routeAdd new cypherpunk.backend.api.v0.account.upgrade.apple(@server, this, 'apple', 'POST')
		@routeAdd new cypherpunk.backend.api.v0.account.upgrade.google(@server, this, 'google', 'POST')

# vim: foldmethod=marker wrap
