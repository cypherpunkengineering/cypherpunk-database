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
	level: cypherpunk.backend.server.power.level.customer
	handler: (req, res) =>
		regionList = {}
		for region of wiz.framework.util.world.regionMap
			regionList[region] = {}
			for country in wiz.framework.util.world.regionMap[region]
				regionList[region][country] = []

		regionList.AS.JP.push # {{{
			id: 'tokyodev3'

			regionName: 'Dev 3, Japan'
			regionLevel: 2000

			ovHostname: 'freebsd-test.tokyo.vpn.cypherpunk.network'
			ovDefault: '185.176.52.34'
			ovNone: '185.176.52.35'
			ovStrong: '185.176.52.36'
			ovStealth: '185.176.52.37'

			ipsecHostname: 'tokyo.vpn.cypherpunk.network'
			ipsecDefault: '185.176.52.38'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.AS.JP.push # {{{
			id: 'tokyodev1'

			regionName: 'Dev 1, Japan'
			regionLevel: 2000

			ovHostname: 'freebsd1.tokyo.vpn.cypherpunk.network'
			ovDefault: '208.111.52.1'
			ovNone: '208.111.52.11'
			ovStrong: '208.111.52.21'
			ovStealth: '208.111.52.31'

			ipsecHostname: 'tokyo.vpn.cypherpunk.network'
			ipsecDefault: '208.111.52.41'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.AS.JP.push # {{{
			id: 'tokyo2'

			regionName: 'Tokyo, Japan'
			regionLevel: 2000

			ovHostname: 'freebsd2.tokyo.vpn.cypherpunk.network'
			ovDefault: '208.111.52.2'
			ovNone: '208.111.52.12'
			ovStrong: '208.111.52.22'
			ovStealth: '208.111.52.32'

			ipsecHostname: 'tokyo.vpn.cypherpunk.network'
			ipsecDefault: '208.111.52.42'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.NA.US.push # {{{
			id: 'honolulu'

			regionName: 'Honolulu, Hawaii'
			regionLevel: 2000

			ovHostname: 'vpn3.honolulu.vpn.cypherpunk.network'
			ovDefault: '208.111.48.146'
			ovNone: '208.111.48.147'
			ovStrong: '208.111.48.148'
			ovStealth: '208.111.48.149'

			ipsecHostname: 'honolulu.vpn.cypherpunk.network'
			ipsecDefault: '208.111.48.150'

			httpDefault: '208.111.48.151'
			socksDefault: '208.111.48.152'

		# }}}
		regionList.NA.US.push # {{{
			id: 'newyork'

			regionName: 'New York, New York'
			regionLevel: 2000

			ovHostname: 'freebsd1.newyork.vpn.cypherpunk.network'
			ovDefault: '204.145.66.35'
			ovNone: '204.145.66.36'
			ovStrong: '204.145.66.37'
			ovStealth: '204.145.66.38'

			ipsecHostname: 'newyork.vpn.cypherpunk.network'
			ipsecDefault: '204.145.66.39'

			httpDefault: '204.145.66.40'
			socksDefault: '204.145.66.41'

		# }}}
		regionList.NA.US.push # {{{
			id: 'siliconvalley'

			regionName: 'Silicon Valley, California'
			regionLevel: 9999

			ovHostname: 'siliconvalley.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'siliconvalley.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.NA.US.push # {{{
			id: 'losangeles'

			regionName: 'Los Angeles, California'
			regionLevel: 2000

			ovHostname: 'freebsd1.losangeles.vpn.cypherpunk.network'
			ovDefault: '174.136.108.243'
			ovNone: '174.136.108.244'
			ovStrong: '174.136.108.245'
			ovStealth: '174.136.108.246'

			ipsecHostname: 'losangeles.vpn.cypherpunk.network'
			ipsecDefault: '174.136.108.247'

			httpDefault: '174.136.108.248'
			socksDefault: '174.136.108.249'

		# }}}
		regionList.NA.US.push # {{{
			id: 'seattle'

			regionName: 'Seattle, Washington'
			regionLevel: 9999

			ovHostname: 'seattle.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'seattle.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.NA.US.push # {{{
			id: 'dallas'

			regionName: 'Dallas, Texas'
			regionLevel: 9999

			ovHostname: 'dallas.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'dallas.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.NA.US.push # {{{
			id: 'atlanta'

			regionName: 'Atlanta, Georgia'
			regionLevel: 9999

			ovHostname: 'atlanta.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'atlanta.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.NA.CA.push # {{{
			id: 'toronto'

			regionName: 'Toronto, Canada'
			regionLevel: 9999

			ovHostname: 'toronto.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'toronto.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.NA.CA.push # {{{
			id: 'vancouver'

			regionName: 'Vancouver, Canada'
			regionLevel: 9999

			ovHostname: 'vancouver.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'vancouver.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.SA.BR.push # {{{
			id: 'saopaulo'

			regionName: 'Sao Paulo, Brazil'
			regionLevel: 9999

			ovHostname: 'saopaulo.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'saopaulo.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.EU.GB.push # {{{
			id: 'london'

			regionName: 'London, UK'
			regionLevel: 9999

			ovHostname: 'london.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'london.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.EU.FR.push # {{{
			id: 'paris'

			regionName: 'Paris, France'
			regionLevel: 9999

			ovHostname: 'freebsd1.paris.vpn.cypherpunk.network'
			ovDefault: '159.8.80.208'
			ovNone: '159.8.80.209'
			ovStrong: '159.8.80.210'
			ovStealth: '159.8.80.211'

			ipsecHostname: 'paris.vpn.cypherpunk.network'
			ipsecDefault: '159.8.80.212'

			httpDefault: '159.8.80.213'
			socksDefault: '159.8.80.214'

		# }}}
		regionList.EU.CH.push # {{{
			id: 'zurich'

			regionName: 'Zurich, Switzerland'
			regionLevel: 9999

			ovHostname: 'zurich.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'zurich.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.EU.NL.push # {{{
			id: 'amsterdam'

			regionName: 'Amsterdam, Netherlands'
			regionLevel: 9999

			ovHostname: 'amsterdam.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'amsterdam.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.EU.DE.push # {{{
			id: 'frankfurt'

			regionName: 'Frankfurt, Germany'
			regionLevel: 9999

			ovHostname: 'frankfurt.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'frankfurt.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.EU.TR.push # {{{
			id: 'istanbul'

			regionName: 'Istanbul, Turkey'
			regionLevel: 9999

			ovHostname: 'istanbul.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'instanbul.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.AS.HK.push # {{{
			id: 'hongkong'

			regionName: 'Hong Kong'
			regionLevel: 9999

			ovHostname: 'hongkong.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'hongkong.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.AS.SG.push # {{{
			id: 'singapore'

			regionName: 'Singapore'
			regionLevel: 9999

			ovHostname: 'singapore.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'singapore.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'
		#}}}

		#console.log regionList
		res.send 200, regionList

# vim: foldmethod=marker wrap
