# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

wiz.package 'cypherpunk.backend.api.v0.network'

class cypherpunk.backend.api.v0.network.module extends cypherpunk.backend.api.base
	database: null
	debug: true

	init: () =>
		#@database = new cypherpunk.backend.db.network(@server, this, @parent.parent.cypherpunkDB)
		# api methods
		@routeAdd new cypherpunk.backend.api.v0.network.status(@server, this, 'status')
		super()

class cypherpunk.backend.api.v0.network.status extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.expired
	mask: cypherpunk.backend.server.power.mask.auth
	#middleware: wiz.framework.http.account.session.refresh
	handler: (req, res) =>

		out =
			queryIP: req.ip

		#console.log out
		res.send 200, out

# vim: foldmethod=marker wrap
