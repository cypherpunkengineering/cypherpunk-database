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

				name: 'Netherlands - Amsterdam'
				nameFull: 'Netherlands - Amsterdam'
				level: 'free'
				servers: 6

				ovHostname: 'amsterdam.cypherpunk.privacy.network'
				ovDefault: [ '185.80.220.94' ]
				ovNone: [ '185.80.220.94' ]
				ovStrong: [ '185.80.220.94' ]
				ovStealth: [ '46.23.78.30' ]

				ipsecHostname: 'amsterdam.cypherpunk.privacy.network'
				ipsecDefault: [ '185.80.220.94' ]

				httpDefault: [ '185.80.220.94' ]
				socksDefault: [ '185.80.220.94' ]

			#}}}
			frankfurt: #{{{
				id: 'frankfurt'
				region: 'EU'
				country: 'DE'

				lat: 50.1109
				lon: 8.6821
				scale: 1.5

				name: 'Germany - Frankfurt'
				nameFull: 'Germany - Frankfurt'
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

				name: 'US - Dallas, TX'
				nameFull: 'US - Dallas, TX'
				level: 'free'
				servers: 3

				ovHostname: 'dallas.cypherpunk.privacy.network'
				ovDefault: [ '173.255.138.20' ]
				ovNone: [ '173.255.138.20' ]
				ovStrong: [ '173.255.138.20' ]
				ovStealth: [ '173.255.138.21' ]

				ipsecHostname: 'dallas.cypherpunk.privacy.network'
				ipsecDefault: [ '173.255.138.20' ]

				httpDefault: [ '173.255.138.20' ]
				socksDefault: [ '173.255.138.20' ]

			#}}}
			hongkong: #{{{
				id: 'hongkong'
				region: 'AS'
				country: 'HK'

				lat: 22.3964
				lon: 114.1095
				scale: 1.5

				name: 'Hong Kong'
				nameFull: 'Hong Kong'
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
			iceland: #{{{
				id: 'iceland'
				region: 'EU'
				country: 'IS'

				lat: 64.1265
				lon: 21.8174
				scale: 1.5

				name: 'Iceland - Reykajvik'
				nameFull: 'Iceland - Reykajvik'
				level: 'free'
				servers: 3

				ovHostname: 'iceland.cypherpunk.privacy.network'
				ovDefault: [ '82.221.133.184' ]
				ovNone: [ '82.221.133.184' ]
				ovStrong: [ '82.221.133.184' ]
				ovStealth: [ '82.221.133.185' ]

				ipsecHostname: 'iceland.cypherpunk.privacy.network'
				ipsecDefault: [ '82.221.133.184' ]

				httpDefault: [ '82.221.133.184' ]
				socksDefault: [ '82.221.133.184' ]

			#}}}
			newyork: #{{{
				default: true
				id: 'newyork'
				region: 'NA'
				country: 'US'

				lat: 40.7128
				lon: -74.0059
				scale: 1

				name: 'US - New York, NY'
				nameFull: 'US - New York, NY'
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

				name: 'US - Los Angeles, CA'
				nameFull: 'US - Los Angeles, CA'
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

				name: 'UK - London'
				nameFull: 'UK - London'
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

				name: 'Canada - Vancouver'
				nameFull: 'Canada - Vancouver'
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

				name: 'US - Atlanta, GA'
				nameFull: 'US - Atlanta, GA'
				level: 'premium'
				servers: 3

				ovHostname: 'atlanta.cypherpunk.privacy.network'
				ovDefault: [ '66.71.252.3' ]
				ovNone: [ '66.71.252.3' ]
				ovStrong: [ '66.71.252.3' ]
				ovStealth: [ '66.71.252.4' ]

				ipsecHostname: 'atlanta.cypherpunk.privacy.network'
				ipsecDefault: [ '66.71.252.3' ]

				httpDefault: [ '66.71.252.3' ]
				socksDefault: [ '66.71.252.3' ]

			#}}}
			chennai: #{{{
				id: 'chennai'
				region: 'AS'
				country: 'IN'

				lat: 13.0827
				lon: 80.2707
				scale: 1

				name: 'India - Chennai'
				nameFull: 'India - Chennai'
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

				name: 'US - Chicago, IL'
				nameFull: 'US - Chicago, IL'
				level: 'premium'
				servers: 3

				ovHostname: 'chicago.cypherpunk.privacy.network'
				ovDefault: [ '104.200.153.226','184.170.250.91' ]
				ovNone: [ '104.200.153.226','184.170.250.91' ]
				ovStrong: [ '104.200.153.226','184.170.250.91' ]
				ovStealth: [ '104.200.153.229','184.170.250.92' ]

				ipsecHostname: 'chicago.cypherpunk.privacy.network'
				ipsecDefault: [ '104.200.153.226','184.170.250.91' ]

				httpDefault: [ '104.200.153.226','184.170.250.91' ]
				socksDefault: [ '104.200.153.226','184.170.250.91' ]

			#}}}
#			istanbul: #{{{
#				id: 'istanbul'
#				region: 'EU'
#				country: 'TR'
#
#				lat: 41.0082
#				lon: 28.9784
#				scale: 1.5
#
#				name: 'Turkey - Istanbul'
#				nameFull: 'Turkey - Istanbul'
#				level: 'premium'
#				servers: 2
#
#				ovHostname: 'istanbul.cypherpunk.privacy.network'
#				ovDefault: [ ]
#				ovNone: [ ]
#				ovStrong: [ ]
#				ovStealth: [ ]
#
#				ipsecHostname: 'instanbul.cypherpunk.privacy.network'
#				ipsecDefault: [ ]
#
#				httpDefault: [ ]
#				socksDefault: [ ]
#
#			#}}}
			miami: #{{{
				id: 'miami'
				region: 'NA'
				country: 'US'

				lat: 25.6717
				lon: -80.1918
				scale: 1

				name: 'US - Miami, FL'
				nameFull: 'US - Miami, FL'
				level: 'premium'
				servers: 2

				ovHostname: 'miami.cypherpunk.privacy.network'
				ovDefault: [ '172.98.76.171' ]
				ovNone: [ '172.98.76.171' ]
				ovStrong: [ '172.98.76.171' ]
				ovStealth: [ '172.98.76.172' ]

				ipsecHostname: 'miami.cypherpunk.privacy.network'
				ipsecDefault: [ '172.98.76.171' ]

				httpDefault: [ '172.98.76.171' ]
				socksDefault: [ '172.98.76.171' ]

			#}}}
			melbourne: #{{{
				id: 'melbourne'
				region: 'OP'
				country: 'AU'

				lat: -37.8136
				lon: 144.9631
				scale: 1

				name: 'Australia - Melbourne'
				nameFull: 'Australia - Melbourne'
				level: 'premium'
				servers: 2

				ovHostname: 'melbourne.cypherpunk.privacy.network'
				ovDefault: [ '209.95.58.60' ]
				ovNone: [ '209.95.58.60' ]
				ovStrong: [ '209.95.58.60' ]
				ovStealth: [ '209.95.58.61' ]

				ipsecHostname: 'melbourne.cypherpunk.privacy.network'
				ipsecDefault: [ '209.95.58.60' ]

				httpDefault: [ '209.95.58.60']
				socksDefault: [ '209.95.58.60' ]

			#}}}
			milan: #{{{
				id: 'milan'
				region: 'EU'
				country: 'IT'

				lat: 45.4654
				lon: 9.1859
				scale: 1.5

				name: 'Italy - Milan'
				nameFull: 'Italy - Milan'
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

				name: 'Canada - Montreal'
				nameFull: 'Canada - Montreal'
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

				name: 'Russia - Moscow'
				nameFull: 'Russia - Moscow'
				level: 'premium'
				servers: 2

				ovHostname: 'moscow.cypherpunk.privacy.network'
				ovDefault: [ '158.255.1.89' ]
				ovNone: [ '158.255.1.89' ]
				ovStrong: [ '158.255.1.89' ]
				ovStealth: [ '158.255.1.90' ]

				ipsecHostname: 'moscow.cypherpunk.privacy.network'
				ipsecDefault: [ '158.255.1.89' ]

				httpDefault: [ '158.255.1.89' ]
				socksDefault: [ '158.255.1.89' ]

			#}}}
			newjersey: #{{{
				id: 'newjersey'
				region: 'NA'
				country: 'US'

				lat: 40.0583
				lon: -74.4057
				scale: 1

				name: 'US - Newark, NJ'
				nameFull: 'US - Newark, NJ'
				level: 'premium'
				servers: 2

				ovHostname: 'newjersey.cypherpunk.privacy.network'
				ovDefault: [ '107.152.101.179' ]
				ovNone: [ '107.152.101.179' ]
				ovStrong: [ '107.152.101.179' ]
				ovStealth: [ '107.152.101.180' ]

				ipsecHostname: 'newjersey.cypherpunk.privacy.network'
				ipsecDefault: [ '107.152.101.179' ]

				httpDefault: [ '107.152.101.179' ]
				socksDefault: [ '107.152.101.179' ]
			#}}}
			oslo: #{{{
				id: 'oslo'
				region: 'EU'
				country: 'NO'

				lat: 59.9139
				lon: 10.7522
				scale: 1.5

				name: 'Norway - Oslo'
				nameFull: 'Norway - Oslo'
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

				name: 'France - Paris'
				nameFull: 'France - Paris'
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

				name: 'US - Phoenix, AZ'
				nameFull: 'US - Phoenix, AZ'
				level: 'premium'
				servers: 2

				ovHostname: 'phoenix.cypherpunk.privacy.network'
				ovDefault: [ '172.98.87.3' ]
				ovNone: [ '172.98.87.3' ]
				ovStrong: [ '172.98.87.3' ]
				ovStealth: [ '172.98.87.4' ]

				ipsecHostname: 'phoenix.cypherpunk.privacy.network'
				ipsecDefault: [ '172.98.87.3' ]

				httpDefault: [ '172.98.87.3' ]
				socksDefault: [ '172.98.87.3' ]
			#}}}
			saltlakecity: #{{{
				id: 'saltlakecity'
				region: 'NA'
				country: 'US'

				lat: 40.7608
				lon: -111.8910
				scale: 1

				name: 'US - Salt Lake City, UT'
				nameFull: 'US - Salt Lake City, UT'
				level: 'premium'
				servers: 2

				ovHostname: 'saltlakecity.cypherpunk.privacy.network'
				ovDefault: [ '107.182.239.208' ]
				ovNone: [ '107.182.239.208' ]
				ovStrong: [ '107.182.239.208' ]
				ovStealth: [ '107.182.239.209' ]

				ipsecHostname: 'saltlakecity.cypherpunk.privacy.network'
				ipsecDefault: [ '107.182.239.208' ]

				httpDefault: [ '107.182.239.208' ]
				socksDefault: [ '107.182.239.208' ]
			#}}}
			sanjose: #{{{
				id: 'sanjose'
				region: 'NA'
				country: 'US'

				lat: 37.3382
				lon: -121.8863
				scale: 1

				name: 'US - San Jose, CA'
				nameFull: 'US - San Jose, CA'
				level: 'free'
				servers: 8

				ovHostname: 'sanjose.cypherpunk.privacy.network'
				ovDefault: [ '173.255.132.80' ]
				ovNone: [ '173.255.132.80' ]
				ovStrong: [ '173.255.132.80' ]
				ovStealth: [ '173.255.132.81' ]

				ipsecHostname: 'sanjose.cypherpunk.privacy.network'
				ipsecDefault: [ '173.255.132.80' ]

				httpDefault: [ '173.255.132.80' ]
				socksDefault: [ '173.255.132.80' ]
			#}}}
			saopaulo: #{{{
				id: 'saopaulo'
				region: 'SA'
				country: 'BR'

				lat: -23.5505
				lon: -46.6333
				scale: 1

				name: 'Brazil - Sao Paulo'
				nameFull: 'Brazil - Sao Paulo'
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

				name: 'US - Seattle, WA'
				nameFull: 'US - Seattle, WA'
				level: 'premium'
				servers: 3

				ovHostname: 'seattle.cypherpunk.privacy.network'
				ovDefault: [ '67.213.209.128' ]
				ovNone: [ '67.213.209.128' ]
				ovStrong: [ '67.213.209.128' ]
				ovStealth: [ '67.213.209.129' ]

				ipsecHostname: 'seattle.cypherpunk.privacy.network'
				ipsecDefault: [ '67.213.209.128' ]

				httpDefault: [ '67.213.209.128' ]
				socksDefault: [ '67.213.209.128' ]

			#}}}
#			siliconvalley: #{{{
#				id: 'siliconvalley'
#				region: 'NA'
#				country: 'US'
#
#				lat: 37.3875
#				lon: -122.0575
#				scale: 1
#
#				name: 'US - Silicon Valley, CA'
#				nameFull: 'US - Silicon Valley, CA'
#				level: 'premium'
#				servers: 8
#
#				ovHostname: 'siliconvalley.cypherpunk.privacy.network'
#				ovDefault: [ ]
#				ovNone: [ ]
#				ovStrong: [ ]
#				ovStealth: [ ]
#
#				ipsecHostname: 'siliconvalley.cypherpunk.privacy.network'
#				ipsecDefault: [ ]
#
#				httpDefault: [ ]
#				socksDefault: [ ]
#
#			#}}}
			singapore: #{{{
				id: 'singapore'
				region: 'AS'
				country: 'SG'

				lat: 1.3521
				lon: 103.8198
				scale: 1.5

				name: 'Singapore'
				nameFull: 'Singapore'
				level: 'premium'
				servers: 3

				ovHostname: 'singapore.cypherpunk.privacy.network'
				ovDefault: [ '173.255.143.60' ]
				ovNone: [ '173.255.143.60' ]
				ovStrong: [ '173.255.143.60' ]
				ovStealth: [ '173.255.143.61' ]

				ipsecHostname: 'singapore.cypherpunk.privacy.network'
				ipsecDefault: [ '173.255.143.60' ]

				httpDefault: [ '173.255.143.60' ]
				socksDefault: [ '173.255.143.60' ]

			#}}}
			stockholm: #{{{
				id: 'stockholm'
				region: 'EU'
				country: 'SE'

				lat: 59.3293
				lon: 18.0686
				scale: 1.5

				name: 'Sweden - Stockholm'
				nameFull: 'Sweden - Stockholm'
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

				name: 'Australia - Sydney'
				nameFull: 'Australia - Sydney'
				level: 'premium'
				servers: 2

				ovHostname: 'sydney.cypherpunk.privacy.network'
				ovDefault: [ '31.24.225.52' ]
				ovNone: [ '31.24.225.52' ]
				ovStrong: [ '31.24.225.52' ]
				ovStealth: [ '31.24.225.53' ]

				ipsecHostname: 'sydney.cypherpunk.privacy.network'
				ipsecDefault: [ '31.24.225.52' ]

				httpDefault: [ '31.24.225.52' ]
				socksDefault: [ '31.24.225.52' ]

			#}}}
			tokyo: #{{{
				id: 'tokyo'
				region: 'AS'
				country: 'JP'

				lat: 35.6895
				lon: 139.6917
				scale: 1.5

				name: 'Japan - Tokyo'
				nameFull: 'Japan - Tokyo'
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

				name: 'Canada - Toronto'
				nameFull: 'Canada - Toronto'
				level: 'premium'
				servers: 2

				ovHostname: 'toronto.cypherpunk.privacy.network'
				ovDefault: [ '209.95.57.40' ]
				ovNone: [ '209.95.57.40' ]
				ovStrong: [ '209.95.57.40' ]
				ovStealth: [ '209.95.57.41' ]

				ipsecHostname: 'toronto.cypherpunk.privacy.network'
				ipsecDefault: [ '209.95.57.40' ]

				httpDefault: [ '209.95.57.40' ]
				socksDefault: [ '209.95.57.40' ]

			#}}}
			washingtondc: #{{{
				id: 'washingtondc'
				region: 'NA'
				country: 'US'

				lat: 38.9072
				lon: -77.0369
				scale: 1

				name: 'US - Washington D.C.'
				nameFull: 'US - Washington D.C.'
				level: 'premium'
				servers: 2

				ovHostname: 'washingtondc.cypherpunk.privacy.network'
				ovDefault: [ '67.213.214.48' ]
				ovNone: [ '67.213.214.48' ]
				ovStrong: [ '67.213.214.48' ]
				ovStealth: [ '67.213.214.49' ]

				ipsecHostname: 'washingtondc.cypherpunk.privacy.network'
				ipsecDefault: [ '67.213.214.48' ]

				httpDefault: [ '67.213.214.48' ]
				socksDefault: [ '67.213.214.48' ]

			#}}}
			zurich: #{{{
				id: 'zurich'
				region: 'EU'
				country: 'CH'

				lat: 47.3769
				lon: 8.5417
				scale: 1.5

				name: 'Switzerland - Zurich'
				nameFull: 'Switzerland - Zurich'
				level: 'premium'
				servers: 2

				ovHostname: 'zurich.cypherpunk.privacy.network'
				ovDefault: [ '81.17.21.194' ]
				ovNone: [ '81.17.21.194' ]
				ovStrong: [ '81.17.21.194' ]
				ovStealth: [ '81.17.21.195' ]

				ipsecHostname: 'zurich.cypherpunk.privacy.network'
				ipsecDefault: [ '81.17.21.194' ]

				httpDefault: [ '81.17.21.194' ]
				socksDefault: [ '81.17.21.194' ]

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
				nameFull: 'Tokyo Core Network'
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
				nameFull: 'Tokyo Test VM 3'
				level: 'developer'
				servers: 1

				ovHostname: 'freebsd-test.cypherpunk.privacy.network'
				ovDefault: [ '185.176.52.34' ]
				ovNone: [ '185.176.52.34' ]
				ovStrong: [ '185.176.52.34' ]
				ovStealth: [ '185.176.52.34' ]

				ipsecHostname: 'test.tokyo.cypherpunk.privacy.network'
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
				nameFull: 'Tokyo Hatos VM'
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
				nameFull: 'Connection failure test'
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
				nameFull: 'Honolulu Test VM'
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
			#out[id].level = "free" if out[id].level is "premium" # temp hack for free preview period
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
