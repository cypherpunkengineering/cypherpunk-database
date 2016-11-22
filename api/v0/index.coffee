# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

require './account'
require './subscription'
require './vpn'
require './location'

wiz.package 'cypherpunk.backend.api.v0'

class cypherpunk.backend.api.v0.module extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	load: () =>
		super()
		@routeAdd new cypherpunk.backend.api.v0.account.module(@server, this, 'account')
		@routeAdd new cypherpunk.backend.api.v0.subscription.module(@server, this, 'subscription')
		@routeAdd new cypherpunk.backend.api.v0.vpn.module(@server, this, 'vpn')
		@routeAdd new cypherpunk.backend.api.v0.location.module(@server, this, 'location')

# POST /api/v0/account/identify/email
# POST /api/v0/account/authenticate/password
# POST /api/v0/account/authenticate/emailpass
# POST /api/v0/account/register/signup
# POST /api/v0/account/update/password
# POST /api/v0/account/update/profile

# POST /api/v0/subscription/purchase
# POST /api/v0/subscription/upgrade
# GET  /api/v0/subscription/status

# GET  /api/v0/vpn/serverList

# vim: foldmethod=marker wrap
