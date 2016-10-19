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

		regionList.AS.JP.push
			id: 'tokyodev3'
			regionName: 'Dev 3, Japan'

			ovHostname: 'freebsd-test.tokyo.vpn.cypherpunk.network'
			ovDefault: '208.111.52.34'
			ovNone: '208.111.52.35'
			ovStrong: '208.111.52.36'
			ovStealth: '208.111.52.37'

			ipsecHostname: 'tokyo.vpn.cypherpunk.network'
			ipsecDefault: '208.111.52.34'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.AS.JP.push
			id: 'tokyodev1'
			regionName: 'Dev 1, Japan'

			ovHostname: 'freebsd1.tokyo.vpn.cypherpunk.network'
			ovDefault: '208.111.52.1'
			ovNone: '208.111.52.11'
			ovStrong: '208.111.52.21'
			ovStealth: '208.111.52.31'

			ipsecHostname: 'tokyo.vpn.cypherpunk.network'
			ipsecDefault: '208.111.52.41'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.AS.JP.push
			id: 'tokyo2'
			regionName: 'Tokyo, Japan'

			ovHostname: 'freebsd2.tokyo.vpn.cypherpunk.network'
			ovDefault: '208.111.52.2'
			ovNone: '208.111.52.12'
			ovStrong: '208.111.52.22'
			ovStealth: '208.111.52.32'

			ipsecHostname: 'tokyo.vpn.cypherpunk.network'
			ipsecDefault: '208.111.52.42'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.NA.US.push
			id: 'honolulu'
			regionName: 'Honolulu, Hawaii'

			ovHostname: 'vpn3.honolulu.vpn.cypherpunk.network'
			ovDefault: '208.111.48.146'
			ovNone: '208.111.48.147'
			ovStrong: '208.111.48.148'
			ovStealth: '208.111.48.149'

			ipsecHostname: 'honolulu.vpn.cypherpunk.network'
			ipsecDefault: '208.111.48.150'

			httpDefault: '208.111.48.151'
			socksDefault: '208.111.48.152'

		regionList.NA.US.push
			id: 'newyork'
			regionName: 'New York, New York'

			ovHostname: 'newyork.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'newyork.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.NA.US.push
			id: 'siliconvalley'
			regionName: 'Silicon Valley, California'

			ovHostname: 'siliconvalley.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'siliconvalley.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.NA.US.push
			id: 'losangeles'
			regionName: 'Los Angeles, California'

			ovHostname: 'losangeles.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'losangeles.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.NA.US.push
			id: 'seattle'
			regionName: 'Seattle, Washington'

			ovHostname: 'seattle.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'seattle.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.NA.US.push
			id: 'dallas'
			regionName: 'Dallas, Texas'

			ovHostname: 'dallas.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'dallas.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.NA.US.push
			id: 'atlanta'
			regionName: 'Atlanta, Georgia'

			ovHostname: 'atlanta.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'atlanta.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.NA.CA.push
			id: 'toronto'
			regionName: 'Toronto, Canada'

			ovHostname: 'toronto.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'toronto.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.NA.CA.push
			id: 'vancouver'
			regionName: 'Vancouver, Canada'

			ovHostname: 'vancouver.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'vancouver.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.SA.BR.push
			id: 'saopaulo'
			regionName: 'Sao Paulo, Brazil'

			ovHostname: 'saopaulo.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'saopaulo.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.EU.GB.push
			id: 'london'
			regionName: 'London, UK'

			ovHostname: 'london.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'london.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.EU.FR.push
			id: 'paris'
			regionName: 'Paris, France'

			ovHostname: 'paris.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'paris.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.EU.CH.push
			id: 'zurich'
			regionName: 'Zurich, Switzerland'

			ovHostname: 'zurich.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'zurich.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.EU.NL.push
			id: 'amsterdam'
			regionName: 'Amsterdam, Netherlands'

			ovHostname: 'amsterdam.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'amsterdam.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.EU.DE.push
			id: 'frankfurt'
			regionName: 'Frankfurt, Germany'

			ovHostname: 'frankfurt.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'frankfurt.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.EU.TR.push
			id: 'istanbul'
			regionName: 'Istanbul, Turkey'

			ovHostname: 'istanbul.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'instanbul.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.AS.HK.push
			id: 'hongkong'
			regionName: 'Hong Kong'

			ovHostname: 'hongkong.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'hongkong.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		regionList.AS.SG.push
			id: 'singapore'
			regionName: 'Singapore'

			ovHostname: 'singapore.vpn.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'singapore.vpn.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#console.log regionList
		res.send 200, regionList
	#}}}

# vim: foldmethod=marker wrap
