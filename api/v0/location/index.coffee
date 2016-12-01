# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

wiz.package 'cypherpunk.backend.api.v0.location'

class cypherpunk.backend.api.v0.location.module extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	database: null

	init: () =>
		#@database = new cypherpunk.backend.db.location(@server, this, @parent.parent.cypherpunkDB)
		# api methods
		@routeAdd new cypherpunk.backend.api.v0.location.list(@server, this, 'list')
		super()


class cypherpunk.backend.api.v0.location.list extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	handler: (req, res) => @handler404(req, res)

	locations:
		free:
			amsterdam: #{{{
				id: 'amsterdam'
				region: 'EU'
				country: 'NL'

				name: 'Amsterdam, Netherlands'
				level: 'free'

				ovHostname: 'amsterdam.cypherpunk.privacy.network'
				ovDefault: [ '185.80.221.5' ]
				ovNone: [ '185.80.221.34' ]
				ovStrong: [ '185.80.221.35' ]
				ovStealth: [ '185.80.221.55' ]

				ipsecHostname: 'amsterdam.cypherpunk.privacy.network'
				ipsecDefault: [ '185.80.221.90' ]

				httpDefault: [ '185.80.221.121' ]
				socksDefault: [ '185.80.221.144' ]

			#}}}
			frankfurt: #{{{
				id: 'frankfurt'
				region: 'EU'
				country: 'DE'

				name: 'Frankfurt, Germany'
				level: 'free'

				ovHostname: 'frankfurt.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'frankfurt.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			dallas: #{{{
				id: 'dallas'
				region: 'NA'
				country: 'US'

				name: 'Dallas, Texas'
				level: 'free'

				ovHostname: 'dallas.cypherpunk.privacy.network'
				ovDefault: [ '104.200.142.50' ]
				ovNone: [ '104.200.142.51' ]
				ovStrong: [ '104.200.142.52' ]
				ovStealth: [ '104.200.142.53' ]

				ipsecHostname: 'dallas.cypherpunk.privacy.network'
				ipsecDefault: [ '104.200.142.54' ]

				httpDefault: [ '104.200.142.55' ]
				socksDefault: [ '104.200.142.56' ]

			#}}}
			hongkong: #{{{
				id: 'hongkong'
				region: 'AS'
				country: 'HK'

				name: 'Hong Kong'
				level: 'free'

				ovHostname: 'hongkong.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'hongkong.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			newyork: #{{{
				id: 'newyork'
				region: 'NA'
				country: 'US'

				name: 'New York, New York'
				level: 'free'

				ovHostname: 'newyork.cypherpunk.privacy.network'
				ovDefault: [ '209.95.51.34' ]
				ovNone: [ '209.95.51.35' ]
				ovStrong: [ '209.95.51.36' ]
				ovStealth: [ '209.95.51.37' ]

				ipsecHostname: 'newyork.cypherpunk.privacy.network'
				ipsecDefault: [ '209.95.51.38' ]

				httpDefault: [ '209.95.51.40' ]
				socksDefault: [ '209.95.51.42' ]

			#}}}
			losangeles: #{{{
				id: 'losangeles'
				region: 'NA'
				country: 'US'

				name: 'Los Angeles, California'
				level: 'free'

				ovHostname: 'losangeles.cypherpunk.privacy.network'
				ovDefault: [ '174.136.108.243' ]
				ovNone: [ '174.136.108.244' ]
				ovStrong: [ '174.136.108.245' ]
				ovStealth: [ '174.136.108.246' ]

				ipsecHostname: 'losangeles.cypherpunk.privacy.network'
				ipsecDefault: [ '174.136.108.247' ]

				httpDefault: [ '174.136.108.248' ]
				socksDefault: [ '174.136.108.249' ]
			#}}}
			london: #{{{
				id: 'london'
				region: 'EU'
				country: 'GB'

				name: 'London, UK'
				level: 'free'

				ovHostname: 'london.cypherpunk.privacy.network'
				ovDefault: [ '88.202.186.223' ]
				ovNone: [ '88.202.186.224' ]
				ovStrong: [ '88.202.186.225' ]
				ovStealth: [ '88.202.186.226' ]

				ipsecHostname: 'london.cypherpunk.privacy.network'
				ipsecDefault: [ '88.202.186.227' ]

				httpDefault: [ '88.202.186.228' ]
				socksDefault: [ '88.202.186.229' ]

			#}}}
			vancouver: #{{{
				id: 'vancouver'
				region: 'NA'
				country: 'CA'

				name: 'Vancouver, Canada'
				level: 'free'

				ovHostname: 'vancouver.cypherpunk.privacy.network'
				ovDefault: [ '107.181.189.146' ]
				ovNone: [ '107.181.189.147' ]
				ovStrong: [ '107.181.189.148' ]
				ovStealth: [ '107.181.189.149' ]

				ipsecHostname: 'vancouver.cypherpunk.privacy.network'
				ipsecDefault: [ '107.181.189.150' ]

				httpDefault: [ '107.181.189.151' ]
				socksDefault: [ '107.181.189.152' ]

			#}}}

		premium:
			atlanta: #{{{
				id: 'atlanta'
				region: 'NA'
				country: 'US'

				name: 'Atlanta, Georgia'
				level: 'premium'

				ovHostname: 'atlanta.cypherpunk.privacy.network'
				ovDefault: [ '172.98.79.242' ]
				ovNone: [ '172.98.79.243' ]
				ovStrong: [ '172.98.79.244' ]
				ovStealth: [ '172.98.79.245' ]

				ipsecHostname: 'atlanta.cypherpunk.privacy.network'
				ipsecDefault: [ '172.98.79.246' ]

				httpDefault: [ '172.98.79.247' ]
				socksDefault: [ '172.98.79.248' ]

			#}}}
			chicago: #{{{
				id: 'chicago'
				region: 'NA'
				country: 'US'

				name: 'Chicago, Illinois'
				level: 'premium'

				ovHostname: 'chicago.cypherpunk.privacy.network'
				ovDefault: [ '104.200.153.226' ]
				ovNone: [ '104.200.153.227' ]
				ovStrong: [ '104.200.153.228' ]
				ovStealth: [ '104.200.153.229' ]

				ipsecHostname: 'chicago.cypherpunk.privacy.network'
				ipsecDefault: [ '104.200.153.230' ]

				httpDefault: [ '104.200.153.231' ]
				socksDefault: [ '104.200.153.232' ]

			#}}}
			istanbul: #{{{
				id: 'istanbul'
				region: 'EU'
				country: 'TR'

				name: 'Istanbul, Turkey'
				level: 'premium'

				ovHostname: 'istanbul.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'instanbul.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			miami: #{{{
				id: 'miami'
				region: 'NA'
				country: 'US'

				name: 'Miami, Florida'
				level: 'premium'

				ovHostname: 'miami.cypherpunk.privacy.network'
				ovDefault: [ '172.98.76.50' ]
				ovNone: [ '172.98.76.51' ]
				ovStrong: [ '172.98.76.52' ]
				ovStealth: [ '172.98.76.53' ]

				ipsecHostname: 'miami.cypherpunk.privacy.network'
				ipsecDefault: [ '172.98.76.54' ]

				httpDefault: [ '172.98.76.55' ]
				socksDefault: [ '172.98.76.56' ]

			#}}}
			paris: #{{{
				id: 'paris'
				region: 'EU'
				country: 'FR'

				name: 'Paris, France'
				level: 'premium'

				ovHostname: 'paris.cypherpunk.privacy.network'
				ovDefault: [ '159.8.80.208' ]
				ovNone: [ '159.8.80.209' ]
				ovStrong: [ '159.8.80.210' ]
				ovStealth: [ '159.8.80.211' ]

				ipsecHostname: 'paris.cypherpunk.privacy.network'
				ipsecDefault: [ '159.8.80.212' ]

				httpDefault: [ '159.8.80.213' ]
				socksDefault: [ '159.8.80.214' ]

			#}}}
			phoenix: #{{{
				id: 'phoenix'
				region: 'NA'
				country: 'US'

				name: 'Phoenix, Arizona'
				level: 'premium'

				ovHostname: 'phoenix.cypherpunk.privacy.network'
				ovDefault: [ '104.200.133.242' ]
				ovNone: [ '104.200.133.243' ]
				ovStrong: [ '104.200.133.244' ]
				ovStealth: [ '104.200.133.245' ]

				ipsecHostname: 'phoenix.cypherpunk.privacy.network'
				ipsecDefault: [ '104.200.133.246' ]

				httpDefault: [ '104.200.133.247' ]
				socksDefault: [ '104.200.133.248' ]
			#}}}
			saltlakecity: #{{{
				id: 'saltlakecity'
				region: 'NA'
				country: 'US'

				name: 'Salt Lake City, Utah'
				level: 'premium'

				ovHostname: 'saltlakecity.cypherpunk.privacy.network'
				ovDefault: [ '173.244.209.73' ]
				ovNone: [ '209.95.56.15' ]
				ovStrong: [ '209.95.56.16' ]
				ovStealth: [ '209.95.56.17' ]

				ipsecHostname: 'saltlakecity.cypherpunk.privacy.network'
				ipsecDefault: [ '209.95.56.18' ]

				httpDefault: [ '209.95.56.19' ]
				socksDefault: [ '209.95.56.20' ]
			#}}}
			saopaulo: #{{{
				id: 'saopaulo'
				region: 'SA'
				country: 'BR'

				name: 'Sao Paulo, Brazil'
				level: 'premium'

				ovHostname: 'saopaulo.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'saopaulo.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			seattle: #{{{
				id: 'seattle'
				region: 'NA'
				country: 'US'

				name: 'Seattle, Washington'
				level: 'premium'

				ovHostname: 'seattle.cypherpunk.privacy.network'
				ovDefault: [ '104.200.129.210' ]
				ovNone: [ '104.200.129.211' ]
				ovStrong: [ '104.200.129.212' ]
				ovStealth: [ '104.200.129.213' ]

				ipsecHostname: 'seattle.cypherpunk.privacy.network'
				ipsecDefault: [ '104.200.129.214' ]

				httpDefault: [ '104.200.129.215' ]
				socksDefault: [ '104.200.129.216' ]

			#}}}
			siliconvalley: #{{{
				id: 'siliconvalley'
				region: 'NA'
				country: 'US'

				name: 'Silicon Valley, California'
				level: 'premium'

				ovHostname: 'siliconvalley.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'siliconvalley.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			singapore: #{{{
				id: 'singapore'
				region: 'AS'
				country: 'SG'

				name: 'Singapore'
				level: 'premium'

				ovHostname: 'singapore.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'singapore.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			toronto: #{{{
				id: 'toronto'
				region: 'NA'
				country: 'CA'

				name: 'Toronto, Canada'
				level: 'premium'

				ovHostname: 'toronto.cypherpunk.privacy.network'
				ovDefault: [ '172.98.66.194' ]
				ovNone: [ '172.98.66.195' ]
				ovStrong: [ '172.98.66.196' ]
				ovStealth: [ '172.98.66.197' ]

				ipsecHostname: 'toronto.cypherpunk.privacy.network'
				ipsecDefault: [ '172.98.66.198' ]

				httpDefault: [ '172.98.66.199' ]
				socksDefault: [ '172.98.66.200' ]

			#}}}
			zurich: #{{{
				id: 'zurich'
				region: 'EU'
				country: 'CH'

				name: 'Zurich, Switzerland'
				level: 'premium'

				ovHostname: 'zurich.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'zurich.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}

		staff:
			losangeles2: #{{{
				id: 'losangeles2'
				region: 'NA'
				country: 'US'

				name: 'Los Angeles 2, California'
				level: 'premium'

				ovHostname: 'losangeles.cypherpunk.privacy.network'
				ovDefault: [ '184.170.243.67' ]
				ovNone: [ '184.170.243.68' ]
				ovStrong: [ '184.170.243.69' ]
				ovStealth: [ '184.170.243.70' ]

				ipsecHostname: 'losangeles.cypherpunk.privacy.network'
				ipsecDefault: [ '184.170.243.71' ]

				httpDefault: [ '184.170.243.72' ]
				socksDefault: [ '184.170.243.73' ]
			#}}}
			newjersey: #{{{
				id: 'newjersey'
				region: 'NA'
				country: 'US'

				name: 'Newark, New Jersey'
				level: 'premium'

				ovHostname: 'newjersey.cypherpunk.privacy.network'
				ovDefault: [ '172.98.78.98' ]
				ovNone: [ '172.98.78.99' ]
				ovStrong: [ '172.98.78.100' ]
				ovStealth: [ '172.98.78.101' ]

				ipsecHostname: 'newjersey.cypherpunk.privacy.network'
				ipsecDefault: [ '172.98.78.102' ]

				httpDefault: [ '172.98.78.103' ]
				socksDefault: [ '172.98.78.104' ]
			#}}}

		developer:
			devtokyo1: #{{{
				id: 'devtokyo1'
				region: 'DEV'
				country: 'JP'

				name: 'Tokyo Core Network'
				level: 'developer'

				ovHostname: 'freebsd1.tokyo.vpn.cypherpunk.network'
				ovDefault: [ '208.111.52.1' ]
				ovNone: [ '208.111.52.11' ]
				ovStrong: [ '208.111.52.21' ]
				ovStealth: [ '208.111.52.31' ]

				ipsecHostname: 'freebsd1.tokyo.vpn.cypherpunk.network'
				ipsecDefault: [ '208.111.52.41' ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			devtokyo3: #{{{
				id: 'devtokyo3'
				region: 'DEV'
				country: 'JP'

				name: 'Tokyo Test VM 3'
				level: 'developer'

				ovHostname: 'tokyo.cypherpunk.privacy.network'
				ovDefault: [ '185.176.52.34' ]
				ovNone: [ '185.176.52.35' ]
				ovStrong: [ '185.176.52.36' ]
				ovStealth: [ '185.176.52.37' ]

				ipsecHostname: 'tokyo.cypherpunk.privacy.network'
				ipsecDefault: [ '185.176.52.38' ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			devhonolulu: #{{{
				id: 'devhonolulu'
				region: 'NA'
				country: 'US'

				name: 'Honolulu, Hawaii'
				level: 'developer'

				ovHostname: 'honolulu.cypherpunk.privacy.network'
				ovDefault: [ '208.111.48.146' ]
				ovNone: [ '208.111.48.147' ]
				ovStrong: [ '208.111.48.148' ]
				ovStealth: [ '208.111.48.149' ]

				ipsecHostname: 'honolulu.cypherpunk.privacy.network'
				ipsecDefault: [ '208.111.48.150' ]

				httpDefault: [ '208.111.48.151' ]
				socksDefault: [ '208.111.48.152' ]

			#}}}

	addLocationsOfType: (out, type, enabled) => #{{{
		for id of @locations[type]
			out[id] = @locations[type][id]
			out[id].enabled = enabled
		return out
	#}}}
	getLocationsByType: (type) => #{{{
		out = {}

		switch type

			when "developer"
				out = @addLocationsOfType(out, "developer", true)
				out = @addLocationsOfType(out, "staff", true)
				out = @addLocationsOfType(out, "premium", true)
				out = @addLocationsOfType(out, "free", true)

			when "staff"
				out = @addLocationsOfType(out, "staff", true)
				out = @addLocationsOfType(out, "premium", true)
				out = @addLocationsOfType(out, "free", true)

			when "premium", "family", "enterprise"
				out = @addLocationsOfType(out, "premium", true)
				out = @addLocationsOfType(out, "free", true)

			when "free"
				out = @addLocationsOfType(out, "premium", false)
				out = @addLocationsOfType(out, "free", true)

		return out
	#}}}
	catchall: (req, res, routeWord) => #{{{
		out = @getLocationsByType(routeWord)

		if not out or typeof out isnt 'object' or Object.keys(out).length < 1
			return @handler404(req, res)

		#console.log out
		res.send 200, out
	#}}}

# vim: foldmethod=marker wrap
