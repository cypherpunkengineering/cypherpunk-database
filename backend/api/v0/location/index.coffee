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
		@routeAdd new cypherpunk.backend.api.v0.location.world(@server, this, 'world')
		super()

class cypherpunk.backend.api.v0.location.world extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	handler: (req, res, routeWord) => #{{{
		# prepare output structure
		out =
			region: {}
			regionOrder: []
			country: {}

		# build region list
		for region in Object.keys(wiz.framework.util.world.regions)
			out.region[region] = wiz.framework.util.world.regions[region]
		# add dev region
		out.region.DEV = 'Development'

		# build region order array, add DEV first
		out.regionOrder = [ 'DEV' ].concat(wiz.framework.util.world.regionOrder)

		# build country list
		for region in Object.keys(wiz.framework.util.world.regions)
			for country in Object.keys(wiz.framework.util.world.countries[region])
				out.country[country] = wiz.framework.util.world.countries[region][country]

		# done
		res.send 200, out
	#}}}

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
				servers: 6

				ovHostname: 'amsterdam.cypherpunk.privacy.network'
				ovDefault: [ '185.80.221.5' ]
				ovNone: [ '185.80.221.5' ]
				ovStrong: [ '185.80.221.5' ]
				ovStealth: [ '185.80.221.55' ]

				ipsecHostname: 'amsterdam.cypherpunk.privacy.network'
				ipsecDefault: [ '185.80.221.5' ]

				httpDefault: [ '185.80.221.5' ]
				socksDefault: [ '185.80.221.5' ]

			#}}}
			frankfurt: #{{{
				id: 'frankfurt'
				region: 'EU'
				country: 'DE'

				name: 'Frankfurt, Germany'
				level: 'free'
				servers: 3

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
				servers: 3

				ovHostname: 'dallas.cypherpunk.privacy.network'
				ovDefault: [ '104.200.142.50' ]
				ovNone: [ '104.200.142.50' ]
				ovStrong: [ '104.200.142.50' ]
				ovStealth: [ '104.200.142.53' ]

				ipsecHostname: 'dallas.cypherpunk.privacy.network'
				ipsecDefault: [ '104.200.142.50' ]

				httpDefault: [ '104.200.142.50' ]
				socksDefault: [ '104.200.142.50' ]

			#}}}
			hongkong: #{{{
				id: 'hongkong'
				region: 'AS'
				country: 'HK'

				name: 'Hong Kong'
				level: 'free'
				servers: 3

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
				default: true

				name: 'New York, New York'
				level: 'free'
				servers: 10

				ovHostname: 'newyork.cypherpunk.privacy.network'
				ovDefault: [ '209.95.51.34' ]
				ovNone: [ '209.95.51.34' ]
				ovStrong: [ '209.95.51.34' ]
				ovStealth: [ '209.95.51.37' ]

				ipsecHostname: 'newyork.cypherpunk.privacy.network'
				ipsecDefault: [ '209.95.51.34' ]

				httpDefault: [ '209.95.51.34' ]
				socksDefault: [ '209.95.51.34' ]

			#}}}
			losangeles: #{{{
				id: 'losangeles'
				region: 'NA'
				country: 'US'

				name: 'Los Angeles, California'
				level: 'free'
				servers: 8

				ovHostname: 'losangeles.cypherpunk.privacy.network'
				ovDefault: [ '184.170.243.67' ]
				ovNone: [ '184.170.243.67' ]
				ovStrong: [ '184.170.243.67' ]
				ovStealth: [ '184.170.243.70' ]

				ipsecHostname: 'losangeles.cypherpunk.privacy.network'
				ipsecDefault: [ '184.170.243.67' ]

				httpDefault: [ '184.170.243.67' ]
				socksDefault: [ '184.170.243.67' ]
			#}}}
			london: #{{{
				id: 'london'
				region: 'EU'
				country: 'GB'

				name: 'London, UK'
				level: 'free'
				servers: 6

				ovHostname: 'london.cypherpunk.privacy.network'
				ovDefault: []# [ '88.202.186.223' ]
				ovNone: []# [ '88.202.186.223' ]
				ovStrong: []# [ '88.202.186.223' ]
				ovStealth: []# [ '88.202.186.226' ]

				ipsecHostname: 'london.cypherpunk.privacy.network'
				ipsecDefault: []# [ '88.202.186.223' ]

				httpDefault: []# [ '88.202.186.223' ]
				socksDefault: []# [ '88.202.186.223' ]

			#}}}
			vancouver: #{{{
				id: 'vancouver'
				region: 'NA'
				country: 'CA'

				name: 'Vancouver, Canada'
				level: 'free'
				servers: 3

				ovHostname: 'vancouver.cypherpunk.privacy.network'
				ovDefault: [ '107.181.189.146' ]
				ovNone: [ '107.181.189.146' ]
				ovStrong: [ '107.181.189.146' ]
				ovStealth: [ '107.181.189.149' ]

				ipsecHostname: 'vancouver.cypherpunk.privacy.network'
				ipsecDefault: [ '107.181.189.146' ]

				httpDefault: [ '107.181.189.146' ]
				socksDefault: [ '107.181.189.146' ]

			#}}}

		premium:
			atlanta: #{{{
				id: 'atlanta'
				region: 'NA'
				country: 'US'

				name: 'Atlanta, Georgia'
				level: 'premium'
				servers: 3

				ovHostname: 'atlanta.cypherpunk.privacy.network'
				ovDefault: [ '172.98.79.242' ]
				ovNone: [ '172.98.79.242' ]
				ovStrong: [ '172.98.79.242' ]
				ovStealth: [ '172.98.79.245' ]

				ipsecHostname: 'atlanta.cypherpunk.privacy.network'
				ipsecDefault: [ '172.98.79.242' ]

				httpDefault: [ '172.98.79.242' ]
				socksDefault: [ '172.98.79.242' ]

			#}}}
			chennai: #{{{
				id: 'chennai'
				region: 'AS'
				country: 'IN'

				name: 'Chennai, India'
				level: 'premium'
				servers: 4

				ovHostname: 'chennai.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'chennai.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			chicago: #{{{
				id: 'chicago'
				region: 'NA'
				country: 'US'

				name: 'Chicago, Illinois'
				level: 'premium'
				servers: 3

				ovHostname: 'chicago.cypherpunk.privacy.network'
				ovDefault: [ '104.200.153.226' ]
				ovNone: [ '104.200.153.226' ]
				ovStrong: [ '104.200.153.226' ]
				ovStealth: [ '104.200.153.229' ]

				ipsecHostname: 'chicago.cypherpunk.privacy.network'
				ipsecDefault: [ '104.200.153.226' ]

				httpDefault: [ '104.200.153.226' ]
				socksDefault: [ '104.200.153.226' ]

			#}}}
			istanbul: #{{{
				id: 'istanbul'
				region: 'EU'
				country: 'TR'

				name: 'Istanbul, Turkey'
				level: 'premium'
				servers: 2

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
				servers: 2

				ovHostname: 'miami.cypherpunk.privacy.network'
				ovDefault: [ '172.98.76.50' ]
				ovNone: [ '172.98.76.50' ]
				ovStrong: [ '172.98.76.50' ]
				ovStealth: [ '172.98.76.53' ]

				ipsecHostname: 'miami.cypherpunk.privacy.network'
				ipsecDefault: [ '172.98.76.50' ]

				httpDefault: [ '172.98.76.50' ]
				socksDefault: [ '172.98.76.50' ]

			#}}}
			melbourne: #{{{
				id: 'melbourne'
				region: 'OP'
				country: 'AU'

				name: 'Melbourne, Australia'
				level: 'premium'
				servers: 2

				ovHostname: 'melbourne.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'melbourne.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			milan: #{{{
				id: 'milan'
				region: 'EU'
				country: 'IT'

				name: 'Milan, Italy'
				level: 'premium'
				servers: 2

				ovHostname: 'milan.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'milan.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			montreal: #{{{
				id: 'montreal'
				region: 'NA'
				country: 'CA'

				name: 'Montreal, Canada'
				level: 'premium'
				servers: 2

				ovHostname: 'montreal.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'montreal.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			moscow: #{{{
				id: 'moscow'
				region: 'EU'
				country: 'RU'

				name: 'Moscow, Russia'
				level: 'premium'
				servers: 2

				ovHostname: 'moscow.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'moscow.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			newjersey: #{{{
				id: 'newjersey'
				region: 'NA'
				country: 'US'

				name: 'Newark, New Jersey'
				level: 'premium'
				servers: 2

				ovHostname: 'newjersey.cypherpunk.privacy.network'
				ovDefault: [ '172.98.78.98' ]
				ovNone: [ '172.98.78.98' ]
				ovStrong: [ '172.98.78.98' ]
				ovStealth: [ '172.98.78.101' ]

				ipsecHostname: 'newjersey.cypherpunk.privacy.network'
				ipsecDefault: [ '172.98.78.98' ]

				httpDefault: [ '172.98.78.98' ]
				socksDefault: [ '172.98.78.98' ]
			#}}}
			oslo: #{{{
				id: 'oslo'
				region: 'EU'
				country: 'NO'

				name: 'Oslo, Norway'
				level: 'premium'
				servers: 2

				ovHostname: 'oslo.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'oslo.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			paris: #{{{
				id: 'paris'
				region: 'EU'
				country: 'FR'

				name: 'Paris, France'
				level: 'premium'
				servers: 3

				ovHostname: 'paris.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'paris.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			phoenix: #{{{
				id: 'phoenix'
				region: 'NA'
				country: 'US'

				name: 'Phoenix, Arizona'
				level: 'premium'
				servers: 2

				ovHostname: 'phoenix.cypherpunk.privacy.network'
				ovDefault: [ '104.200.133.242' ]
				ovNone: [ '104.200.133.242' ]
				ovStrong: [ '104.200.133.242' ]
				ovStealth: [ '104.200.133.245' ]

				ipsecHostname: 'phoenix.cypherpunk.privacy.network'
				ipsecDefault: [ '104.200.133.242' ]

				httpDefault: [ '104.200.133.242' ]
				socksDefault: [ '104.200.133.242' ]
			#}}}
			saltlakecity: #{{{
				id: 'saltlakecity'
				region: 'NA'
				country: 'US'

				name: 'Salt Lake City, Utah'
				level: 'premium'
				servers: 2

				ovHostname: 'saltlakecity.cypherpunk.privacy.network'
				ovDefault: [ '173.244.209.73' ]
				ovNone: [ '173.244.209.73' ]
				ovStrong: [ '173.244.209.73' ]
				ovStealth: [ '209.95.56.17' ]

				ipsecHostname: 'saltlakecity.cypherpunk.privacy.network'
				ipsecDefault: [ '173.244.209.73' ]

				httpDefault: [ '173.244.209.73' ]
				socksDefault: [ '173.244.209.73' ]
			#}}}
			saopaulo: #{{{
				id: 'saopaulo'
				region: 'SA'
				country: 'BR'

				name: 'Sao Paulo, Brazil'
				level: 'premium'
				servers: 3

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
				servers: 3

				ovHostname: 'seattle.cypherpunk.privacy.network'
				ovDefault: [ '104.200.129.210' ]
				ovNone: [ '104.200.129.210' ]
				ovStrong: [ '104.200.129.210' ]
				ovStealth: [ '104.200.129.213' ]

				ipsecHostname: 'seattle.cypherpunk.privacy.network'
				ipsecDefault: [ '104.200.129.210' ]

				httpDefault: [ '104.200.129.210' ]
				socksDefault: [ '104.200.129.210' ]

			#}}}
			siliconvalley: #{{{
				id: 'siliconvalley'
				region: 'NA'
				country: 'US'

				name: 'Silicon Valley, California'
				level: 'premium'
				servers: 8

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
				servers: 3

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
			stockholm: #{{{
				id: 'stockholm'
				region: 'EU'
				country: 'SE'

				name: 'Stockholm, Sweden'
				level: 'premium'
				servers: 2

				ovHostname: 'stockholm.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'stockholm.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			sydney: #{{{
				id: 'sydney'
				region: 'OP'
				country: 'AU'

				name: 'Sydney, Australia'
				level: 'premium'
				servers: 2

				ovHostname: 'sydney.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'sydney.cypherpunk.privacy.network'
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
				servers: 2

				ovHostname: 'toronto.cypherpunk.privacy.network'
				ovDefault: [ '172.98.66.194' ]
				ovNone: [ '172.98.66.194' ]
				ovStrong: [ '172.98.66.194' ]
				ovStealth: [ '172.98.66.197' ]

				ipsecHostname: 'toronto.cypherpunk.privacy.network'
				ipsecDefault: [ '172.98.66.194' ]

				httpDefault: [ '172.98.66.194' ]
				socksDefault: [ '172.98.66.194' ]

			#}}}
			washingtondc: #{{{
				id: 'washingtondc'
				region: 'NA'
				country: 'US'

				name: 'Washington D.C.'
				level: 'premium'
				servers: 2

				ovHostname: 'washingtondc.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'washingtondc.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			zurich: #{{{
				id: 'zurich'
				region: 'EU'
				country: 'CH'

				name: 'Zurich, Switzerland'
				level: 'premium'
				servers: 2

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
			devtokyo1: #{{{
				id: 'devtokyo1'
				region: 'DEV'
				country: 'JP'

				name: 'Tokyo Core Network'
				level: 'developer'
				servers: 1

				ovHostname: 'freebsd1.tokyo.vpn.cypherpunk.network'
				ovDefault: [ '185.176.52.2' ]
				ovNone: [ '185.176.52.2' ]
				ovStrong: [ '185.176.52.2' ]
				ovStealth: [ '185.176.52.3' ]

				ipsecHostname: 'freebsd1.tokyo.vpn.cypherpunk.network'
				ipsecDefault: [ '185.176.52.2' ]

				httpDefault: [ '185.176.52.2' ]
				socksDefault: [ '185.176.52.2' ]

			#}}}

		developer:
			devtokyo3: #{{{
				id: 'devtokyo3'
				region: 'DEV'
				country: 'JP'

				name: 'Tokyo Test VM 3'
				level: 'developer'
				servers: 1

				ovHostname: 'tokyo.cypherpunk.privacy.network'
				ovDefault: [ '185.176.52.34' ]
				ovNone: [ '185.176.52.34' ]
				ovStrong: [ '185.176.52.34' ]
				ovStealth: [ '185.176.52.34' ]

				ipsecHostname: 'tokyo.cypherpunk.privacy.network'
				ipsecDefault: [ '185.176.52.34' ]

				httpDefault: [ '185.176.52.34' ]
				socksDefault: [ '185.176.52.34' ]

			#}}}
			devtokyo4: #{{{
				id: 'devtokyo4'
				region: 'DEV'
				country: 'JP'

				name: 'Tokyo Hatos VM'
				level: 'developer'
				servers: 1

				ovHostname: 'tokyo.cypherpunk.privacy.network'
				ovDefault: [ '185.176.52.7' ]
				ovNone: [ '185.176.52.7' ]
				ovStrong: [ '185.176.52.7' ]
				ovStealth: [ '185.176.52.7' ]

				ipsecHostname: 'tokyo.cypherpunk.privacy.network'
				ipsecDefault: [ '185.176.52.38' ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			devhonolulu: #{{{
				id: 'devhonolulu'
				region: 'DEV'
				country: 'JP'

				name: 'Honolulu Test VM'
				level: 'developer'
				servers: 1

				ovHostname: 'honolulu.cypherpunk.privacy.network'
				ovDefault: [ '208.111.48.146' ]
				ovNone: [ '208.111.48.146' ]
				ovStrong: [ '208.111.48.146' ]
				ovStealth: [ '208.111.48.149' ]

				ipsecHostname: 'honolulu.cypherpunk.privacy.network'
				ipsecDefault: [ '208.111.48.146' ]

				httpDefault: [ '208.111.48.146' ]
				socksDefault: [ '208.111.48.146' ]

			#}}}

	catchall: (req, res, routeWord) =>
		out = @getLocationsByType(routeWord)
		if not out or typeof out isnt 'object' or Object.keys(out).length < 1
			return @handler404(req, res)

		res.send 200, out

	addLocationsOfType: (out, type, enabled) => #{{{
		for id of @locations[type]
			out[id] = @locations[type][id]
			out[id].enabled = enabled
			out[id].authorized = enabled
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

# vim: foldmethod=marker wrap
