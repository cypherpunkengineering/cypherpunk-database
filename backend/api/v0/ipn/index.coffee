require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../../db/user'

require './paypal'

wiz.package 'cypherpunk.backend.api.v0.ipn'

class cypherpunk.backend.api.v0.ipn.module extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	load: () =>
		super()
		@routeAdd new cypherpunk.backend.api.v0.ipn.paypal(@server, this, 'paypal', 'POST')

# vim: foldmethod=marker wrap