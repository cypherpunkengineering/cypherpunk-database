# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

wiz.package 'cypherpunk.backend.api.v0.vpn'

class cypherpunk.backend.api.v0.vpn.module extends cypherpunk.backend.api.base
	database: null

	init: () =>
		#@database = new cypherpunk.backend.db.vpn(@server, this, @parent.parent.cypherpunkDB)
		# api methods
		@routeAdd new cypherpunk.backend.api.v0.vpn.certificate(@server, this, 'certificate')
		super()

class cypherpunk.backend.api.v0.vpn.certificate extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.free
	handler: (req, res) =>
		#{{{
		p12 = "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"
		#}}}

		out =
			p12: p12

		#console.log out
		res.send 200, out

# vim: foldmethod=marker wrap