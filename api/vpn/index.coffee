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
			city: 'Tokyo Development'
			commonName: 'freebsd-test.tokyo.vpn.cypherpunk.network'
			ipDefault: '208.111.52.34'
			ipNone: '208.111.52.35'
			ipStrong: '208.111.52.36'
			ipStealth: '208.111.52.37'

		regionList.AS.JP.push
			city: 'Tokyo Production'
			commonName: 'freebsd2.tokyo.vpn.cypherpunk.network'
			ipDefault: '208.111.52.2'
			ipNone: '208.111.52.12'
			ipStrong: '208.111.52.22'
			ipStealth: '208.111.52.32'

		regionList.NA.US.push
			city: 'New York'
			commonName: 'newyork.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.NA.US.push
			city: 'Silicon Valley'
			commonName: 'siliconvalley.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.NA.US.push
			city: 'Los Angeles'
			commonName: 'losangeles.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.NA.US.push
			city: 'Seattle'
			commonName: 'seattle.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.NA.US.push
			city: 'dallas'
			commonName: 'dallas.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.NA.US.push
			city: 'Atlanta'
			commonName: 'atlanta.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.NA.US.push
			city: 'Honolulu'
			commonName: 'honolulu.vpn.cypherpunk.network'
			ipDefault: '199.68.252.203'
			ipNone: '199.68.252.203'
			ipStrong: '199.68.252.203'
			ipStealth: '199.68.252.203'

		regionList.NA.CA.push
			city: 'Toronto'
			commonName: 'toronto.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.NA.CA.push
			city: 'vancouver'
			commonName: 'vancouver.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.SA.BR.push
			city: 'Sao Paulo'
			commonName: 'saopaulo.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.EU.GB.push
			city: 'London'
			commonName: 'london.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.EU.FR.push
			city: 'Paris'
			commonName: 'paris.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.EU.CH.push
			city: 'Zurich'
			commonName: 'zurich.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.EU.NL.push
			city: 'Amsterdam'
			commonName: 'Amsterdam.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.EU.DE.push
			city: 'Germany'
			commonName: 'frankfurt.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.EU.TR.push
			city: 'Istanbul'
			commonName: 'istanbul.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.AS.HK.push
			city: 'Hong Kong'
			commonName: 'hongkong.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		regionList.AS.SG.push
			city: 'Singapore'
			commonName: 'singapore.vpn.cypherpunk.network'
			ipDefault: '255.255.255.255'
			ipNone: '255.255.255.255'
			ipStrong: '255.255.255.255'
			ipStealth: '255.255.255.255'

		#console.log regionList
		res.send 200, regionList
	#}}}

# vim: foldmethod=marker wrap
