# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/acct/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

wiz.package 'cypherpunk.backend.api.vpn'

class cypherpunk.backend.api.vpn.resource extends cypherpunk.backend.api.base
	database: null

	init: () =>
		#@database = new cypherpunk.backend.db.vpn(@server, this, @parent.wizDB)
		# api methods
		@routeAdd new cypherpunk.backend.api.vpn.serverList(@server, this, 'serverList')
		super()

class cypherpunk.backend.api.vpn.serverList extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.customer
	handler: (req, res) => #{{{
		regionList = {}
		for region of wiz.framework.util.world.regionMap
			regionList[region] = {}
			for country in wiz.framework.util.world.regionMap[region]
				regionList[region][country] = []
				regionList[region][country].push
					city: 'Location 1'
					ip: '1.2.3.4'
				regionList[region][country].push
					city: 'Location 2'
					ip: '5.6.7.8'

		res.send 200, regionList
	#}}}

# vim: foldmethod=marker wrap
