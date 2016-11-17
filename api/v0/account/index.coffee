# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../../db/customer'

require './register'
require './confirm'

wiz.package 'cypherpunk.backend.api.v0.account'

class cypherpunk.backend.api.v0.account.module extends wiz.framework.http.account.module
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	database: null

	load: () => #{{{
		super()

		# public account creation api
		@routeAdd new cypherpunk.backend.api.v0.account.register.resource(@server, this, 'register')
		# public account confirmation api
		@routeAdd new cypherpunk.backend.api.v0.account.confirm.resource(@server, this, 'confirm')
	#}}}
	init: () => #{{{
		@database = new cypherpunk.backend.db.customer(@server, this, @parent.parent.cypherpunkDB)
		super()
	#}}}

# vim: foldmethod=marker wrap
