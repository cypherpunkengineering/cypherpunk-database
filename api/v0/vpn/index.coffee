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
		regionList.AS.JP.push # {{{
			id: 'tokyo2'

			regionName: 'Tokyo, Japan'
			regionEnabled: true

			ovHostname: 'tokyo.cypherpunk.privacy.network'
			ovDefault: '208.111.52.2'
			ovNone: '208.111.52.12'
			ovStrong: '208.111.52.22'
			ovStealth: '208.111.52.32'

			ipsecHostname: 'tokyo.cypherpunk.privacy.network'
			ipsecDefault: '208.111.52.42'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.NA.US.push # {{{
			id: 'honolulu'

			regionName: 'Honolulu, Hawaii'
			regionEnabled: true

			ovHostname: 'honolulu.cypherpunk.privacy.network'
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
			regionEnabled: true

			ovHostname: 'newyork.cypherpunk.privacy.network'
			ovDefault: '209.95.51.34'
			ovNone: '209.95.51.35'
			ovStrong: '209.95.51.36'
			ovStealth: '209.95.51.37'

			ipsecHostname: 'newyork.cypherpunk.privacy.network'
			ipsecDefault: '209.95.51.38'

			httpDefault: '209.95.51.40'
			socksDefault: '209.95.51.42'

		# }}}
		regionList.NA.US.push # {{{
			id: 'newjersey'

			regionName: 'Newark, New Jersey'
			regionEnabled: true

			ovHostname: 'newjersey.cypherpunk.privacy.network'
			ovDefault: '172.98.78.98'
			ovNone: '172.98.78.99'
			ovStrong: '172.98.78.100'
			ovStealth: '172.98.78.101'

			ipsecHostname: 'newjersey.cypherpunk.privacy.network'
			ipsecDefault: '172.98.78.102'

			httpDefault: '172.98.78.103'
			socksDefault: '172.98.78.104'

		# }}}
		regionList.NA.US.push # {{{
			id: 'siliconvalley'

			regionName: 'Silicon Valley, California'
			regionEnabled: false

			ovHostname: 'siliconvalley.cypherpunk.privacy.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'siliconvalley.cypherpunk.privacy.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.NA.US.push # {{{
			id: 'losangeles'

			regionName: 'Los Angeles, California'
			regionEnabled: true

			ovHostname: 'losangeles.cypherpunk.privacy.network'
			ovDefault: '174.136.108.243'
			ovNone: '174.136.108.244'
			ovStrong: '174.136.108.245'
			ovStealth: '174.136.108.246'

			ipsecHostname: 'losangeles.cypherpunk.privacy.network'
			ipsecDefault: '174.136.108.247'

			httpDefault: '174.136.108.248'
			socksDefault: '174.136.108.249'

		# }}}
		regionList.NA.US.push # {{{
			id: 'losangeles2'

			regionName: 'Los Angeles2, California'
			regionEnabled: false

			ovHostname: 'losangeles.cypherpunk.privacy.network'
			ovDefault: '162.216.46.242'
			ovNone: '162.216.46.243'
			ovStrong: '162.216.46.244'
			ovStealth: '162.216.46.245'

			ipsecHostname: 'losangeles.cypherpunk.privacy.network'
			ipsecDefault: '162.216.46.246'

			httpDefault: '162.216.46.247'
			socksDefault: '162.216.46.248'

		# }}}
		regionList.NA.US.push # {{{
			id: 'seattle'

			regionName: 'Seattle, Washington'
			regionEnabled: true

			ovHostname: 'seattle.cypherpunk.privacy.network'
			ovDefault: '104.200.129.210'
			ovNone: '104.200.129.211'
			ovStrong: '104.200.129.212'
			ovStealth: '104.200.129.213'

			ipsecHostname: 'seattle.cypherpunk.privacy.network'
			ipsecDefault: '104.200.129.214'

			httpDefault: '104.200.129.215'
			socksDefault: '104.200.129.216'

		# }}}
		regionList.NA.US.push # {{{
			id: 'dallas'

			regionName: 'Dallas, Texas'
			regionEnabled: true

			ovHostname: 'dallas.cypherpunk.privacy.network'
			ovDefault: '104.200.142.50'
			ovNone: '104.200.142.51'
			ovStrong: '104.200.142.52'
			ovStealth: '104.200.142.53'

			ipsecHostname: 'dallas.cypherpunk.privacy.network'
			ipsecDefault: '104.200.142.54'

			httpDefault: '104.200.142.55'
			socksDefault: '104.200.142.56'

		# }}}
		regionList.NA.US.push # {{{
			id: 'atlanta'

			regionName: 'Atlanta, Georgia'
			regionEnabled: false

			ovHostname: 'atlanta.cypherpunk.privacy.network'
			ovDefault: '172.98.49.242'
			ovNone: '172.98.49.243'
			ovStrong: '172.98.49.244'
			ovStealth: '172.98.49.245'

			ipsecHostname: 'atlanta.cypherpunk.privacy.network'
			ipsecDefault: '172.98.49.246'

			httpDefault: '172.98.49.247'
			socksDefault: '172.98.49.248'

		# }}}
		regionList.NA.US.push # {{{
			id: 'miami'

			regionName: 'Miami, Florida'
			regionEnabled: true

			ovHostname: 'miami.cypherpunk.privacy.network'
			ovDefault: '172.98.76.50'
			ovNone: '172.98.76.51'
			ovStrong: '172.98.76.52'
			ovStealth: '172.98.76.53'

			ipsecHostname: 'miami.cypherpunk.privacy.network'
			ipsecDefault: '172.98.76.54'

			httpDefault: '172.98.76.55'
			socksDefault: '172.98.76.56'

		# }}}
		regionList.NA.US.push # {{{
			id: 'saltlakecity'

			regionName: 'Salt Lake City, Utah'
			regionEnabled: true

			ovHostname: 'saltlakecity.cypherpunk.privacy.network'
			ovDefault: '173.244.209.73'
			ovNone: '209.95.56.15'
			ovStrong: '209.95.56.16'
			ovStealth: '209.95.56.17'

			ipsecHostname: 'saltlakecity.cypherpunk.privacy.network'
			ipsecDefault: '209.95.56.18'

			httpDefault: '209.95.56.19'
			socksDefault: '209.95.56.20'

		# }}}
		regionList.NA.US.push # {{{
			id: 'phoenix'

			regionName: 'Phoenix, Arizona'
			regionEnabled: true

			ovHostname: 'phoenix.cypherpunk.privacy.network'
			ovDefault: '104.200.133.242'
			ovNone: '104.200.133.243'
			ovStrong: '104.200.133.244'
			ovStealth: '104.200.133.245'

			ipsecHostname: 'saltlakecity.cypherpunk.privacy.network'
			ipsecDefault: '104.200.133.246'

			httpDefault: '104.200.133.247'
			socksDefault: '104.200.133.248'

		# }}}
		regionList.NA.CA.push # {{{
			id: 'toronto'

			regionName: 'Toronto, Canada'
			regionEnabled: true

			ovHostname: 'toronto.cypherpunk.privacy.network'
			ovDefault: '172.98.66.194'
			ovNone: '172.98.66.195'
			ovStrong: '172.98.66.196'
			ovStealth: '172.98.66.197'

			ipsecHostname: 'toronto.cypherpunk.privacy.network'
			ipsecDefault: '172.98.66.198'

			httpDefault: '172.98.66.199'
			socksDefault: '172.98.66.200'

		# }}}
		regionList.NA.CA.push # {{{
			id: 'vancouver'

			regionName: 'Vancouver, Canada'
			regionEnabled: true

			ovHostname: 'vancouver.cypherpunk.privacy.network'
			ovDefault: '107.181.189.146'
			ovNone: '107.181.189.147'
			ovStrong: '107.181.189.148'
			ovStealth: '107.181.189.149'

			ipsecHostname: 'vancouver.cypherpunk.privacy.network'
			ipsecDefault: '107.181.189.150'

			httpDefault: '107.181.189.151'
			socksDefault: '107.181.189.152'

		# }}}
		regionList.SA.BR.push # {{{
			id: 'saopaulo'

			regionName: 'Sao Paulo, Brazil'
			regionEnabled: false

			ovHostname: 'saopaulo.cypherpunk.privacy.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'saopaulo.cypherpunk.privacy.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.EU.GB.push # {{{
			id: 'london'

			regionName: 'London, UK'
			regionEnabled: true

			ovHostname: 'london.cypherpunk.privacy.network'
			ovDefault: '88.202.186.223'
			ovNone: '88.202.186.224'
			ovStrong: '88.202.186.225'
			ovStealth: '88.202.186.226'

			ipsecHostname: 'london.cypherpunk.privacy.network'
			ipsecDefault: '88.202.186.227'

			httpDefault: '88.202.186.228'
			socksDefault: '88.202.186.229'

		# }}}
		regionList.EU.FR.push # {{{
			id: 'paris'

			regionName: 'Paris, France'
			regionEnabled: true

			ovHostname: 'paris.cypherpunk.privacy.network'
			ovDefault: '159.8.80.208'
			ovNone: '159.8.80.209'
			ovStrong: '159.8.80.210'
			ovStealth: '159.8.80.211'

			ipsecHostname: 'paris.cypherpunk.privacy.network'
			ipsecDefault: '159.8.80.212'

			httpDefault: '159.8.80.213'
			socksDefault: '159.8.80.214'

		# }}}
		regionList.EU.CH.push # {{{
			id: 'zurich'

			regionName: 'Zurich, Switzerland'
			regionEnabled: false

			ovHostname: 'zurich.cypherpunk.privacy.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'zurich.cypherpunk.privacy.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.EU.NL.push # {{{
			id: 'amsterdam'

			regionName: 'Amsterdam, Netherlands'
			regionEnabled: true

			ovHostname: 'amsterdam.cypherpunk.privacy.network'
			ovDefault: '185.80.221.5'
			ovNone: '185.80.221.34'
			ovStrong: '185.80.221.35'
			ovStealth: '185.80.221.55'

			ipsecHostname: 'amsterdam.cypherpunk.privacy.network'
			ipsecDefault: '185.80.221.90'

			httpDefault: '185.80.221.121'
			socksDefault: '185.80.221.144'

		# }}}
		regionList.EU.DE.push # {{{
			id: 'frankfurt'

			regionName: 'Frankfurt, Germany'
			regionEnabled: false

			ovHostname: 'frankfurt.cypherpunk.privacy.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'frankfurt.cypherpunk.privacy.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.EU.TR.push # {{{
			id: 'istanbul'

			regionName: 'Istanbul, Turkey'
			regionEnabled: false

			ovHostname: 'istanbul.cypherpunk.privacy.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'instanbul.cypherpunk.privacy.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.AS.HK.push # {{{
			id: 'hongkong'

			regionName: 'Hong Kong'
			regionEnabled: false

			ovHostname: 'hongkong.cypherpunk.privacy.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'hongkong.cypherpunk.privacy.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		# }}}
		regionList.AS.SG.push # {{{
			id: 'singapore'

			regionName: 'Singapore'
			regionEnabled: false

			ovHostname: 'singapore.cypherpunk.privacy.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'singapore.cypherpunk.privacy.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'
		#}}}

		#console.log regionList
		res.send 200, regionList

# vim: foldmethod=marker wrap
