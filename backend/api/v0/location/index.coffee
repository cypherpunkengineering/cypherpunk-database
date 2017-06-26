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

				lat: 52.3702
				lon: 4.8952
				scale: 1.5

				name: 'Amsterdam, Netherlands'
				level: 'free'
				servers: 6

				ovHostname: 'amsterdam.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [  ]

				ipsecHostname: 'amsterdam.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			frankfurt: #{{{
				id: 'frankfurt'
				region: 'EU'
				country: 'DE'

				lat: 50.1109
				lon: 8.6821
				scale: 1.5

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

				lat: 32.7767
				lon: -96.7970
				scale: 1

				name: 'Dallas, Texas'
				level: 'free'
				servers: 3

				ovHostname: 'dallas.cypherpunk.privacy.network'
				ovDefault: [] #[ '104.200.142.50' ]
				ovNone: [] #[ '104.200.142.50' ]
				ovStrong: [] #[ '104.200.142.50' ]
				ovStealth: [] #[ '104.200.142.53' ]

				ipsecHostname: 'dallas.cypherpunk.privacy.network'
				ipsecDefault: [] #[ '104.200.142.50' ]

				httpDefault: [] #[ '104.200.142.50' ]
				socksDefault: [] #[ '104.200.142.50' ]

			#}}}
			hongkong: #{{{
				id: 'hongkong'
				region: 'AS'
				country: 'HK'

				lat: 22.3964
				lon: 114.1095
				scale: 1.5

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

				lat: 40.7128
				lon: -74.0059
				scale: 1

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

				lat: 34.0522
				lon: -118.2437
				scale: 1

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

				lat: 51.5074
				lon: 0.1278
				scale: 1.5

				name: 'London, UK'
				level: 'free'
				servers: 6

				ovHostname: 'london.cypherpunk.privacy.network'
				ovDefault: [ '88.202.186.223' ]
				ovNone: [ '88.202.186.223' ]
				ovStrong: [ '88.202.186.223' ]
				ovStealth: [ '88.202.186.226' ]

				ipsecHostname: 'london.cypherpunk.privacy.network'
				ipsecDefault: [ '88.202.186.223' ]

				httpDefault: [ '88.202.186.223' ]
				socksDefault: [ '88.202.186.223' ]

			#}}}
			vancouver: #{{{
				id: 'vancouver'
				region: 'NA'
				country: 'CA'

				lat: 49.2827
				lon: -123.1207
				scale: 1

				name: 'Vancouver, Canada'
				level: 'free'
				servers: 3

				ovHostname: 'vancouver.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'vancouver.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}

		premium:
			atlanta: #{{{
				id: 'atlanta'
				region: 'NA'
				country: 'US'

				lat: 33.7490
				lon: -84.3880
				scale: 1

				name: 'Atlanta, Georgia'
				level: 'premium'
				servers: 3

				ovHostname: 'atlanta.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'atlanta.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			chennai: #{{{
				id: 'chennai'
				region: 'AS'
				country: 'IN'

				lat: 13.0827
				lon: 80.2707
				scale: 1

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

				lat: 41.8781
				lon: -87.6298
				scale: 1

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

				lat: 41.0082
				lon: 28.9784
				scale: 1.5

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

				lat: 25.6717
				lon: -80.1918
				scale: 1

				name: 'Miami, Florida'
				level: 'premium'
				servers: 2

				ovHostname: 'miami.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'miami.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			melbourne: #{{{
				id: 'melbourne'
				region: 'OP'
				country: 'AU'

				lat: -37.8136
				lon: 144.9631
				scale: 1

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

				lat: 45.4654
				lon: 9.1859
				scale: 1.5

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

				lat: 45.5017
				lon: -73.5673
				scale: 1

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

				lat: 55.7558
				lon: 37.6173
				scale: 1

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

				lat: 40.0583
				lon: -74.4057
				scale: 1

				name: 'Newark, New Jersey'
				level: 'premium'
				servers: 2

				ovHostname: 'newjersey.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'newjersey.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]
			#}}}
			oslo: #{{{
				id: 'oslo'
				region: 'EU'
				country: 'NO'

				lat: 59.9139
				lon: 10.7522
				scale: 1.5

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

				lat: 48.8566
				lon: 2.3522
				scale: 1.5

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

				lat: 33.4484
				lon: -112.0740
				scale: 1

				name: 'Phoenix, Arizona'
				level: 'premium'
				servers: 2

				ovHostname: 'phoenix.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'phoenix.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]
			#}}}
			saltlakecity: #{{{
				id: 'saltlakecity'
				region: 'NA'
				country: 'US'

				lat: 40.7608
				lon: -111.8910
				scale: 1

				name: 'Salt Lake City, Utah'
				level: 'premium'
				servers: 2

				ovHostname: 'saltlakecity.cypherpunk.privacy.network'
				ovDefault: [ ]
				ovNone: [ ]
				ovStrong: [ ]
				ovStealth: [ ]

				ipsecHostname: 'saltlakecity.cypherpunk.privacy.network'
				ipsecDefault: [ ]

				httpDefault: [ ]
				socksDefault: [ ]
			#}}}
			saopaulo: #{{{
				id: 'saopaulo'
				region: 'SA'
				country: 'BR'

				lat: -23.5505
				lon: -46.6333
				scale: 1

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

				lat: 47.6062
				lon: -122.3321
				scale: 1

				name: 'Seattle, Washington'
				level: 'premium'
				servers: 3

				ovHostname: 'seattle.cypherpunk.privacy.network'
				ovDefault: [] #[ '104.200.129.210' ]
				ovNone: [] #[ '104.200.129.210' ]
				ovStrong: [] #[ '104.200.129.210' ]
				ovStealth: [] #[ '104.200.129.213' ]

				ipsecHostname: 'seattle.cypherpunk.privacy.network'
				ipsecDefault: [] #[ '104.200.129.210' ]

				httpDefault: [] #[ '104.200.129.210' ]
				socksDefault: [] #[ '104.200.129.210' ]

			#}}}
			siliconvalley: #{{{
				id: 'siliconvalley'
				region: 'NA'
				country: 'US'

				lat: 37.3875
				lon: -122.0575
				scale: 1

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

				lat: 1.3521
				lon: 103.8198
				scale: 1.5

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

				lat: 59.3293
				lon: 18.0686
				scale: 1.5

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

				lat: -33.8688
				lon: 151.2093
				scale: 1

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
			tokyo: #{{{
				id: 'tokyo'
				region: 'AS'
				country: 'JP'

				lat: 35.6895
				lon: 139.6917
				scale: 1.5

				name: 'Tokyo, Japan'
				level: 'premium'
				servers: 1

				ovHostname: 'tokyo.cypherpunk.privacy.network'
				ovDefault: [ '173.244.192.232' ]
				ovNone: [ '173.244.192.232' ]
				ovStrong: [ '173.244.192.232' ]
				ovStealth: [ '173.244.192.233' ]

				ipsecHostname: 'tokyo.cypherpunk.privacy.network'
				ipsecDefault: [ '173.244.192.232' ]

				httpDefault: [ '173.244.192.232' ]
				socksDefault: [ '173.244.192.232' ]

			#}}}
			toronto: #{{{
				id: 'toronto'
				region: 'NA'
				country: 'CA'

				lat: 43.6532
				lon: -79.3832
				scale: 1

				name: 'Toronto, Canada'
				level: 'premium'
				servers: 2

				ovHostname: 'toronto.cypherpunk.privacy.network'
				ovDefault: [] #[ '172.98.66.194' ]
				ovNone: [] #[ '172.98.66.194' ]
				ovStrong: [] #[ '172.98.66.194' ]
				ovStealth: [] #[ '172.98.66.197' ]

				ipsecHostname: 'toronto.cypherpunk.privacy.network'
				ipsecDefault: [] #[ '172.98.66.194' ]

				httpDefault: [] #[ '172.98.66.194' ]
				socksDefault: [] #[ '172.98.66.194' ]

			#}}}
			washingtondc: #{{{
				id: 'washingtondc'
				region: 'NA'
				country: 'US'

				lat: 38.9072
				lon: -77.0369
				scale: 1

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

				lat: 47.3769
				lon: 8.5417
				scale: 1.5

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

				lat: 35.6895
				lon: 139.6917
				scale: 1.5

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

				lat: 35.6895
				lon: 139.6917
				scale: 1.5

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

				lat: 35.6895
				lon: 139.6917
				scale: 1.5

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
			devkim: #{{{
				id: 'devkim'
				region: 'DEV'
				country: 'JP'

				lat: 35.6895
				lon: 139.6917
				scale: 1.5

				name: 'Connection failure test'
				level: 'developer'
				servers: 1

				ovHostname: 'fail.tokyo.cypherpunk.privacy.network'
				ovDefault: [ '185.176.52.7' ]
				ovNone: [ '185.176.52.7' ]
				ovStrong: [ '185.176.52.7' ]
				ovStealth: [ '185.176.52.7' ]

				ipsecHostname: 'fail.tokyo.cypherpunk.privacy.network'
				ipsecDefault: [ '185.176.52.38' ]

				httpDefault: [ ]
				socksDefault: [ ]

			#}}}
			devhonolulu: #{{{
				id: 'devhonolulu'
				region: 'DEV'
				country: 'JP'

				lat: 21.3069
				lon: -157.8533
				scale: 4

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

			when "pending", "invitation", "expired"
				out = @addLocationsOfType(out, "premium", false)
				out = @addLocationsOfType(out, "free", false)

		return out
	#}}}

# vim: foldmethod=marker wrap
