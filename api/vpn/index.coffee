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
					city: 'Tokyo Development'
					commonName: 'freebsd-test.tokyo.vpn.cypherpunk.network'
					ipDefault: '208.111.52.34'
					ipNone: '208.111.52.35'
					ipStrong: '208.111.52.36'
					ipStealth: '208.111.52.37'
				regionList[region][country].push
					city: 'Tokyo Production'
					commonName: 'freebsd2.tokyo.vpn.cypherpunk.network'
					ipDefault: '208.111.52.2'
					ipNone: '208.111.52.12'
					ipStrong: '208.111.52.22'
					ipStealth: '208.111.52.32'
				regionList[region][country].push
					city: 'Honolulu'
					commonName: 'honolulu.vpn.cypherpunk.network'
					ipDefault: '199.68.252.203'
					ipNone: '199.68.252.203'
					ipStrong: '199.68.252.203'
					ipStealth: '199.68.252.203'

		#console.log regionList
		res.send 200, regionList
	#}}}

# vim: foldmethod=marker wrap
