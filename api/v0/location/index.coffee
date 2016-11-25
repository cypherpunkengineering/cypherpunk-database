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

	locations: () =>
		locations =
		newyork: #{{{
			id: 'newyork'
			region: 'NA'
			country: 'US'

			name: 'New York, New York'
			enabled: true

			ovHostname: 'freebsd1.newyork.location.cypherpunk.network'
			ovDefault: [ '204.145.66.35', '204.145.66.35', '204.145.66.35' ]
			ovNone: [ '204.145.66.36', '204.145.66.36', '204.145.66.36' ]
			ovStrong: [ '204.145.66.37', '204.145.66.37', '204.145.66.37' ]
			ovStealth: [ '204.145.66.38', '204.145.66.38', '204.145.66.38' ]

			ipsecHostname: 'newyork.location.cypherpunk.network'
			ipsecDefault: [ '204.145.66.39', '204.145.66.39', '204.145.66.39' ]

			httpDefault: [ '204.145.66.40', '204.145.66.40', '204.145.66.40' ]
			socksDefault: [ '204.145.66.41', '204.145.66.41', '204.145.66.41' ]

		#}}}
		siliconvalley: #{{{
			id: 'siliconvalley'
			region: 'NA'
			country: 'US'

			name: 'Silicon Valley, California'
			enabled: false

			ovHostname: 'siliconvalley.location.cypherpunk.network'
			ovDefault: [ ]
			ovNone: [ ]
			ovStrong: [ ]
			ovStealth: [ ]

			ipsecHostname: 'siliconvalley.location.cypherpunk.network'
			ipsecDefault: [ ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		losangeles: #{{{
			id: 'losangeles'
			region: 'NA'
			country: 'US'

			name: 'Los Angeles, California'
			enabled: true

			ovHostname: 'freebsd1.losangeles.location.cypherpunk.network'
			ovDefault: [ '174.136.108.243', '174.136.108.243', '174.136.108.243' ]
			ovNone: [ '174.136.108.244', '174.136.108.244', '174.136.108.244' ]
			ovStrong: [ '174.136.108.245', '174.136.108.245', '174.136.108.245' ]
			ovStealth: [ '174.136.108.246', '174.136.108.246', '174.136.108.246' ]

			ipsecHostname: 'losangeles.location.cypherpunk.network'
			ipsecDefault: [ '174.136.108.247', '174.136.108.247', '174.136.108.247' ]

			httpDefault: [ '174.136.108.248', '174.136.108.248', '174.136.108.248' ]
			socksDefault: [ '174.136.108.249', '174.136.108.249', '174.136.108.249' ]

		#}}}
		seattle: #{{{
			id: 'seattle'
			region: 'NA'
			country: 'US'

			name: 'Seattle, Washington'
			enabled: false

			ovHostname: 'seattle.location.cypherpunk.network'
			ovDefault: [ ]
			ovNone: [ ]
			ovStrong: [ ]
			ovStealth: [ ]

			ipsecHostname: 'seattle.location.cypherpunk.network'
			ipsecDefault: [ ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		dallas: #{{{
			id: 'dallas'
			region: 'NA'
			country: 'US'

			name: 'Dallas, Texas'
			enabled: false

			ovHostname: 'dallas.location.cypherpunk.network'
			ovDefault: [ ]
			ovNone: [ ]
			ovStrong: [ ]
			ovStealth: [ ]

			ipsecHostname: 'dallas.location.cypherpunk.network'
			ipsecDefault: [ ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		atlanta: #{{{
			id: 'atlanta'
			region: 'NA'
			country: 'US'

			name: 'Atlanta, Georgia'
			enabled: false

			ovHostname: 'atlanta.location.cypherpunk.network'
			ovDefault: [ ]
			ovNone: [ ]
			ovStrong: [ ]
			ovStealth: [ ]

			ipsecHostname: 'atlanta.location.cypherpunk.network'
			ipsecDefault: [ ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}

		toronto: #{{{
			id: 'toronto'
			region: 'NA'
			country: 'CA'

			name: 'Toronto, Canada'
			enabled: false

			ovHostname: 'toronto.location.cypherpunk.network'
			ovDefault: [ ]
			ovNone: [ ]
			ovStrong: [ ]
			ovStealth: [ ]

			ipsecHostname: 'toronto.location.cypherpunk.network'
			ipsecDefault: [ ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		vancouver: #{{{
			id: 'vancouver'
			region: 'NA'
			country: 'CA'

			name: 'Vancouver, Canada'
			enabled: false

			ovHostname: 'vancouver.location.cypherpunk.network'
			ovDefault: [ ]
			ovNone: [ ]
			ovStrong: [ ]
			ovStealth: [ ]

			ipsecHostname: 'vancouver.location.cypherpunk.network'
			ipsecDefault: [ ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		saopaulo: #{{{
			id: 'saopaulo'
			region: 'SA'
			country: 'BR'

			name: 'Sao Paulo, Brazil'
			enabled: false

			ovHostname: 'saopaulo.location.cypherpunk.network'
			ovDefault: [ ]
			ovNone: [ ]
			ovStrong: [ ]
			ovStealth: [ ]

			ipsecHostname: 'saopaulo.location.cypherpunk.network'
			ipsecDefault: [ ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		london: #{{{
			id: 'london'
			region: 'EU'
			country: 'GB'

			name: 'London, UK'
			enabled: false

			ovHostname: 'london.location.cypherpunk.network'
			ovDefault: [ ]
			ovNone: [ ]
			ovStrong: [ ]
			ovStealth: [ ]

			ipsecHostname: 'london.location.cypherpunk.network'
			ipsecDefault: [ ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		paris: #{{{
			id: 'paris'
			region: 'EU'
			country: 'FR'

			name: 'Paris, France'
			enabled: true

			ovHostname: 'freebsd1.paris.location.cypherpunk.network'
			ovDefault: [ '159.8.80.208', '159.8.80.208', '159.8.80.208' ]
			ovNone: [ '159.8.80.209', '159.8.80.209', '159.8.80.209' ]
			ovStrong: [ '159.8.80.210', '159.8.80.210', '159.8.80.210' ]
			ovStealth: [ '159.8.80.211', '159.8.80.211', '159.8.80.211' ]

			ipsecHostname: 'paris.location.cypherpunk.network'
			ipsecDefault: [ '159.8.80.212', '159.8.80.212', '159.8.80.212' ]

			httpDefault: [ '159.8.80.213', '159.8.80.213', '159.8.80.213' ]
			socksDefault: [ '159.8.80.214', '159.8.80.214', '159.8.80.214' ]

		#}}}
		zurich: #{{{
			id: 'zurich'
			region: 'EU'
			country: 'CH'

			name: 'Zurich, Switzerland'
			enabled: false

			ovHostname: 'zurich.location.cypherpunk.network'
			ovDefault: [ ]
			ovNone: [ ]
			ovStrong: [ ]
			ovStealth: [ ]

			ipsecHostname: 'zurich.location.cypherpunk.network'
			ipsecDefault: [ ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		amsterdam: #{{{
			id: 'amsterdam'
			region: 'EU'
			country: 'NL'

			name: 'Amsterdam, Netherlands'
			enabled: false

			ovHostname: 'amsterdam.location.cypherpunk.network'
			ovDefault: [ ]
			ovNone: [ ]
			ovStrong: [ ]
			ovStealth: [ ]

			ipsecHostname: 'amsterdam.location.cypherpunk.network'
			ipsecDefault: [ ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		frankfurt: #{{{
			id: 'frankfurt'
			region: 'EU'
			country: 'DE'

			name: 'Frankfurt, Germany'
			enabled: false

			ovHostname: 'frankfurt.location.cypherpunk.network'
			ovDefault: [ ]
			ovNone: [ ]
			ovStrong: [ ]
			ovStealth: [ ]

			ipsecHostname: 'frankfurt.location.cypherpunk.network'
			ipsecDefault: [ ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		istanbul: #{{{
			id: 'istanbul'
			region: 'EU'
			country: 'TR'

			name: 'Istanbul, Turkey'
			enabled: false

			ovHostname: 'istanbul.location.cypherpunk.network'
			ovDefault: [ ]
			ovNone: [ ]
			ovStrong: [ ]
			ovStealth: [ ]

			ipsecHostname: 'instanbul.location.cypherpunk.network'
			ipsecDefault: [ ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		hongkong: #{{{
			id: 'hongkong'
			region: 'AS'
			country: 'HK'

			name: 'Hong Kong'
			enabled: false

			ovHostname: 'hongkong.location.cypherpunk.network'
			ovDefault: [ ]
			ovNone: [ ]
			ovStrong: [ ]
			ovStealth: [ ]

			ipsecHostname: 'hongkong.location.cypherpunk.network'
			ipsecDefault: [ ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		singapore: #{{{
			id: 'singapore'
			region: 'AS'
			country: 'SG'

			name: 'Singapore'
			enabled: false

			ovHostname: 'singapore.location.cypherpunk.network'
			ovDefault: [ ]
			ovNone: [ ]
			ovStrong: [ ]
			ovStealth: [ ]

			ipsecHostname: 'singapore.location.cypherpunk.network'
			ipsecDefault: [ ]

			httpDefault: [ ]
			socksDefault: [ ]
		#}}}

		tokyodev3: #{{{
			id: 'devtokyo3'
			region: 'DEV'
			country: 'JP'

			name: 'Dev 3'
			enabled: true

			ovHostname: 'freebsd-test.tokyo.location.cypherpunk.network'
			ovDefault: [ '185.176.52.34', '185.176.52.34', '185.176.52.34' ]
			ovNone: [ '185.176.52.35', '185.176.52.35', '185.176.52.35' ]
			ovStrong: [ '185.176.52.36', '185.176.52.36', '185.176.52.36' ]
			ovStealth: [ '185.176.52.37', '185.176.52.37', '185.176.52.37' ]

			ipsecHostname: 'tokyo.location.cypherpunk.network'
			ipsecDefault: [ '185.176.52.38', '185.176.52.38', '185.176.52.38' ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		tokyodev1: #{{{
			id: 'devtokyo1'
			region: 'DEV'
			country: 'JP'

			name: 'Dev 1'
			enabled: true

			ovHostname: 'freebsd1.tokyo.location.cypherpunk.network'
			ovDefault: [ '208.111.52.1', '208.111.52.1', '208.111.52.1' ]
			ovNone: [ '208.111.52.11', '208.111.52.11', '208.111.52.11' ]
			ovStrong: [ '208.111.52.21', '208.111.52.21', '208.111.52.21' ]
			ovStealth: [ '208.111.52.31', '208.111.52.31', '208.111.52.31' ]

			ipsecHostname: 'tokyo.location.cypherpunk.network'
			ipsecDefault: [ '208.111.52.41', '208.111.52.41', '208.111.52.41' ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		devtokyo2: #{{{
			id: 'devtokyo2'
			region: 'DEV'
			country: 'JP'

			name: 'Dev 2'
			enabled: true

			ovHostname: 'freebsd2.tokyo.location.cypherpunk.network'
			ovDefault: [ '208.111.52.2', '208.111.52.2', '208.111.52.2' ]
			ovNone: [ '208.111.52.12', '208.111.52.12', '208.111.52.12' ]
			ovStrong: [ '208.111.52.22', '208.111.52.22', '208.111.52.22' ]
			ovStealth: [ '208.111.52.32', '208.111.52.32', '208.111.52.32' ]

			ipsecHostname: 'tokyo.location.cypherpunk.network'
			ipsecDefault: [ '208.111.52.42', '208.111.52.42', '208.111.52.42' ]

			httpDefault: [ ]
			socksDefault: [ ]

		#}}}
		honolulu: #{{{
			id: 'devhonolulu'
			region: 'NA'
			country: 'US'

			name: 'Honolulu, Hawaii'
			enabled: true

			ovHostname: 'location3.honolulu.location.cypherpunk.network'
			ovDefault: [ '208.111.48.146', '208.111.48.146', '208.111.48.146' ]
			ovNone: [ '208.111.48.147', '208.111.48.147', '208.111.48.147' ]
			ovStrong: [ '208.111.48.148', '208.111.48.148', '208.111.48.148' ]
			ovStealth: [ '208.111.48.149', '208.111.48.149', '208.111.48.149' ]

			ipsecHostname: 'honolulu.location.cypherpunk.network'
			ipsecDefault: [ '208.111.48.150', '208.111.48.150', '208.111.48.150' ]

			httpDefault: [ '208.111.48.151', '208.111.48.151', '208.111.48.151' ]
			socksDefault: [ '208.111.48.152', '208.111.48.152', '208.111.48.152' ]

		#}}}

		return locations

	catchall: (req, res, routeWord) => #{{{
		switch routeWord
			when "free"
				locations = @locations()
			when "premium", "family", "enterprise"
				locations = @locations()
			when "developer"
				locations = @locations()
			else return @handler404(req, res)

		#console.log locations
		res.send 200, locations
	#}}}

# vim: foldmethod=marker wrap
