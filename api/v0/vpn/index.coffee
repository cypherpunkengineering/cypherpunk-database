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
		@routeAdd new cypherpunk.backend.api.v0.vpn.serverList(@server, this, 'serverList')
		super()

class cypherpunk.backend.api.v0.vpn.serverList extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.free
	handler: (req, res) =>
		regionList = {}
		for region of wiz.framework.util.world.regionMap
			regionList[region] = {}
			for country in wiz.framework.util.world.regionMap[region]
				regionList[region][country] = []

		# This API is no longer used
		# see new /api/v0/location/list/<accountType>
		regionList.AS.JP.push # {{{
			id: 'tokyodev3'

			regionName: 'Dev 3, Japan'
			regionEnabled: true

			ovHostname: 'tokyo.cypherpunk.privacy.network'
			ovDefault: '185.176.52.34'
			ovNone: '185.176.52.35'
			ovStrong: '185.176.52.36'
			ovStealth: '185.176.52.37'

			ipsecHostname: 'tokyo.cypherpunk.privacy.network'
			ipsecDefault: '185.176.52.38'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.AS.JP.push # {{{
			id: 'tokyodev1'

			regionName: 'Dev 1, Japan'
			regionEnabled: true

			ovHostname: 'freebsd1.tokyo.vpn.cypherpunk.network'
			ovDefault: '208.111.52.1'
			ovNone: '208.111.52.11'
			ovStrong: '208.111.52.21'
			ovStealth: '208.111.52.31'

			ipsecHostname: 'freebsd1.tokyo.vpn.cypherpunk.network'
			ipsecDefault: '208.111.52.41'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		#console.log regionList
		res.send 200, regionList

# vim: foldmethod=marker wrap
