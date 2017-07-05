require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

#require './email'
require './password'

wiz.package 'cypherpunk.backend.api.v0.account.change'

class cypherpunk.backend.api.v0.account.change.resource extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.expired
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.refresh
	nav: false

	load: () =>
		# inherit
		super()

		# public account creation api
		#@routeAdd new cypherpunk.backend.api.v0.account.change.email(@server, this, 'email', 'POST')
		@routeAdd new cypherpunk.backend.api.v0.account.change.password(@server, this, 'password', 'POST')

# vim: foldmethod=marker wrap
