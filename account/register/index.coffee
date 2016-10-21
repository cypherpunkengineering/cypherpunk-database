# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/acct'
require './_framework/http/resource/base'
require './_framework/money/stripe'

wiz.package 'cypherpunk.backend.account.register'

class cypherpunk.backend.account.register.signup extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	handler: (req, res) => #{{{
		@server.root.api.user.database.signup(req, res)
	#}}}

class cypherpunk.backend.account.register.module extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	load: () =>
		# inherit
		super()

		# public account creation api
		@routeAdd new cypherpunk.backend.account.register.signup(@server, this, 'signup', 'POST')

# vim: foldmethod=marker wrap
