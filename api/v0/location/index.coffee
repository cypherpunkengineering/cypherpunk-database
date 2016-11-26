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
			newjersey: #{{{
				id: 'newjersey'
				region: 'NA'
				country: 'US'

				name: 'Newark, New Jersey'

				ovHostname: 'newjersey.cypherpunk.privacy.network'
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
			istanbul: #{{{
				id: 'istanbul'
				region: 'EU'
				country: 'TR'

				name: 'Istanbul, Turkey'

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
			paris: #{{{
				id: 'paris'
				region: 'EU'
				country: 'FR'

				name: 'Paris, France'

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
			miami: #{{{
				id: 'miami'
				region: 'NA'
				country: 'US'

				name: 'Miami, Florida'

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
			phoenix: #{{{
				id: 'phoenix'
				region: 'NA'
				country: 'US'

				name: 'Phoenix, Arizona'

				ovHostname: 'phoenix.cypherpunk.privacy.network'
				ovDefault: [ '104.200.133.242' ]
				ovNone: [ '104.200.133.243' ]
				ovStrong: [ '104.200.133.244' ]
				ovStealth: [ '104.200.133.245' ]

				ipsecHostname: 'saltlakecity.cypherpunk.privacy.network'
				ipsecDefault: [ '104.200.133.246' ]

				httpDefault: [ '104.200.133.247' ]
				socksDefault: [ '104.200.133.248' ]
			#}}}
			saltlakecity: #{{{
				id: 'saltlakecity'
				region: 'NA'
				country: 'US'

				name: 'Salt Lake City, Utah'

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

		developer:
			atlanta: #{{{
				id: 'atlanta'
				region: 'NA'
				country: 'US'

				name: 'Atlanta, Georgia'

				ovHostname: 'atlanta.cypherpunk.privacy.network'
				ovDefault: [ '172.98.49.242' ]
				ovNone: [ '172.98.49.243' ]
				ovStrong: [ '172.98.49.244' ]
				ovStealth: [ '172.98.49.245' ]

				ipsecHostname: 'atlanta.cypherpunk.privacy.network'
				ipsecDefault: [ '172.98.49.246' ]

				httpDefault: [ '172.98.49.247' ]
				socksDefault: [ '172.98.49.248' ]

			#}}}
			losangeles2: #{{{
				id: 'losangeles2'
				region: 'NA'
				country: 'US'

				name: 'Los Angeles 2, California'

				ovHostname: 'losangeles.cypherpunk.privacy.network'
				ovDefault: [ '162.216.46.242' ]
				ovNone: [ '162.216.46.243' ]
				ovStrong: [ '162.216.46.244' ]
				ovStealth: [ '162.216.46.245' ]

				ipsecHostname: 'losangeles.cypherpunk.privacy.network'
				ipsecDefault: [ '162.216.46.246' ]

				httpDefault: [ '162.216.46.247' ]
				socksDefault: [ '162.216.46.248' ]
			#}}}
			devtokyo1: #{{{
				id: 'devtokyo1'
				region: 'DEV'
				country: 'JP'

				name: 'Dev 1'

				ovHostname: 'freebsd1.tokyo.cypherpunk.privacy.network'
				ovDefault: [ '208.111.52.1' ]
				ovNone: [ '208.111.52.11' ]
				ovStrong: [ '208.111.52.21' ]
				ovStealth: [ '208.111.52.31' ]

				ipsecHostname: 'tokyo.cypherpunk.privacy.network'
				ipsecDefault: [ '208.111.52.41' ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			devtokyo2: #{{{
				id: 'devtokyo2'
				region: 'DEV'
				country: 'JP'

				name: 'Dev 2'

				ovHostname: 'freebsd2.tokyo.cypherpunk.privacy.network'
				ovDefault: [ '208.111.52.2' ]
				ovNone: [ '208.111.52.12' ]
				ovStrong: [ '208.111.52.22' ]
				ovStealth: [ '208.111.52.32' ]

				ipsecHostname: 'tokyo.cypherpunk.privacy.network'
				ipsecDefault: [ '208.111.52.42' ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			devtokyo3: #{{{
				id: 'devtokyo3'
				region: 'DEV'
				country: 'JP'

				name: 'Tokyo Dev 3, Japan'

				ovHostname: 'freebsd-test.tokyo.cypherpunk.privacy.network'
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
