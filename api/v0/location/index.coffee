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

			regionName: 'New York, New York'
			regionEnabled: true

			ovHostname: 'freebsd1.newyork.location.cypherpunk.network'
			ovDefault: '204.145.66.35'
			ovNone: '204.145.66.36'
			ovStrong: '204.145.66.37'
			ovStealth: '204.145.66.38'

			ipsecHostname: 'newyork.location.cypherpunk.network'
			ipsecDefault: '204.145.66.39'

			httpDefault: '204.145.66.40'
			socksDefault: '204.145.66.41'

		#}}}
		siliconvalley: #{{{
			id: 'siliconvalley'
			region: 'NA'
			country: 'US'

			regionName: 'Silicon Valley, California'
			regionEnabled: false

			ovHostname: 'siliconvalley.location.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'siliconvalley.location.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		losangeles: #{{{
			id: 'losangeles'
			region: 'NA'
			country: 'US'

			regionName: 'Los Angeles, California'
			regionEnabled: true

			ovHostname: 'freebsd1.losangeles.location.cypherpunk.network'
			ovDefault: '174.136.108.243'
			ovNone: '174.136.108.244'
			ovStrong: '174.136.108.245'
			ovStealth: '174.136.108.246'

			ipsecHostname: 'losangeles.location.cypherpunk.network'
			ipsecDefault: '174.136.108.247'

			httpDefault: '174.136.108.248'
			socksDefault: '174.136.108.249'

		#}}}
		seattle: #{{{
			id: 'seattle'
			region: 'NA'
			country: 'US'

			regionName: 'Seattle, Washington'
			regionEnabled: false

			ovHostname: 'seattle.location.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'seattle.location.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		dallas: #{{{
			id: 'dallas'
			region: 'NA'
			country: 'US'

			regionName: 'Dallas, Texas'
			regionEnabled: false

			ovHostname: 'dallas.location.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'dallas.location.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		atlanta: #{{{
			id: 'atlanta'
			region: 'NA'
			country: 'US'

			regionName: 'Atlanta, Georgia'
			regionEnabled: false

			ovHostname: 'atlanta.location.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'atlanta.location.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}

		toronto: #{{{
			id: 'toronto'
			region: 'NA'
			country: 'CA'

			regionName: 'Toronto, Canada'
			regionEnabled: false

			ovHostname: 'toronto.location.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'toronto.location.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		vancouver: #{{{
			id: 'vancouver'
			region: 'NA'
			country: 'CA'

			regionName: 'Vancouver, Canada'
			regionEnabled: false

			ovHostname: 'vancouver.location.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'vancouver.location.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		saopaulo: #{{{
			id: 'saopaulo'
			region: 'SA'
			country: 'BR'

			regionName: 'Sao Paulo, Brazil'
			regionEnabled: false

			ovHostname: 'saopaulo.location.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'saopaulo.location.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		london: #{{{
			id: 'london'
			region: 'EU'
			country: 'GB'

			regionName: 'London, UK'
			regionEnabled: false

			ovHostname: 'london.location.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'london.location.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		paris: #{{{
			id: 'paris'
			region: 'EU'
			country: 'FR'

			regionName: 'Paris, France'
			regionEnabled: true

			ovHostname: 'freebsd1.paris.location.cypherpunk.network'
			ovDefault: '159.8.80.208'
			ovNone: '159.8.80.209'
			ovStrong: '159.8.80.210'
			ovStealth: '159.8.80.211'

			ipsecHostname: 'paris.location.cypherpunk.network'
			ipsecDefault: '159.8.80.212'

			httpDefault: '159.8.80.213'
			socksDefault: '159.8.80.214'

		#}}}
		zurich: #{{{
			id: 'zurich'
			region: 'EU'
			country: 'CH'

			regionName: 'Zurich, Switzerland'
			regionEnabled: false

			ovHostname: 'zurich.location.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'zurich.location.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		amsterdam: #{{{
			id: 'amsterdam'
			region: 'EU'
			country: 'NL'

			regionName: 'Amsterdam, Netherlands'
			regionEnabled: false

			ovHostname: 'amsterdam.location.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'amsterdam.location.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		frankfurt: #{{{
			id: 'frankfurt'
			region: 'EU'
			country: 'DE'

			regionName: 'Frankfurt, Germany'
			regionEnabled: false

			ovHostname: 'frankfurt.location.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'frankfurt.location.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		istanbul: #{{{
			id: 'istanbul'
			region: 'EU'
			country: 'TR'

			regionName: 'Istanbul, Turkey'
			regionEnabled: false

			ovHostname: 'istanbul.location.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'instanbul.location.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		hongkong: #{{{
			id: 'hongkong'
			region: 'AS'
			country: 'HK'

			regionName: 'Hong Kong'
			regionEnabled: false

			ovHostname: 'hongkong.location.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'hongkong.location.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		singapore: #{{{
			id: 'singapore'
			region: 'AS'
			country: 'SG'

			regionName: 'Singapore'
			regionEnabled: false

			ovHostname: 'singapore.location.cypherpunk.network'
			ovDefault: '255.255.255.255'
			ovNone: '255.255.255.255'
			ovStrong: '255.255.255.255'
			ovStealth: '255.255.255.255'

			ipsecHostname: 'singapore.location.cypherpunk.network'
			ipsecDefault: '255.255.255.255'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'
		#}}}

		tokyodev3: #{{{
			id: 'tokyodev3'
			region: 'AS'
			country: 'JP'

			regionName: 'Dev 3, Japan'
			regionEnabled: true

			ovHostname: 'freebsd-test.tokyo.location.cypherpunk.network'
			ovDefault: '185.176.52.34'
			ovNone: '185.176.52.35'
			ovStrong: '185.176.52.36'
			ovStealth: '185.176.52.37'

			ipsecHostname: 'tokyo.location.cypherpunk.network'
			ipsecDefault: '185.176.52.38'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		tokyodev1: #{{{
			id: 'tokyodev1'
			region: 'AS'
			country: 'JP'

			regionName: 'Dev 1, Japan'
			regionEnabled: true

			ovHostname: 'freebsd1.tokyo.location.cypherpunk.network'
			ovDefault: '208.111.52.1'
			ovNone: '208.111.52.11'
			ovStrong: '208.111.52.21'
			ovStealth: '208.111.52.31'

			ipsecHostname: 'tokyo.location.cypherpunk.network'
			ipsecDefault: '208.111.52.41'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		tokyo2: #{{{
			id: 'tokyo2'
			region: 'AS'
			country: 'JP'

			regionName: 'Tokyo, Japan'
			regionEnabled: true

			ovHostname: 'freebsd2.tokyo.location.cypherpunk.network'
			ovDefault: '208.111.52.2'
			ovNone: '208.111.52.12'
			ovStrong: '208.111.52.22'
			ovStealth: '208.111.52.32'

			ipsecHostname: 'tokyo.location.cypherpunk.network'
			ipsecDefault: '208.111.52.42'

			httpDefault: '255.255.255.255'
			socksDefault: '255.255.255.255'

		#}}}
		honolulu: #{{{
			id: 'honolulu'
			region: 'NA'
			country: 'US'

			regionName: 'Honolulu, Hawaii'
			regionEnabled: true

			ovHostname: 'location3.honolulu.location.cypherpunk.network'
			ovDefault: '208.111.48.146'
			ovNone: '208.111.48.147'
			ovStrong: '208.111.48.148'
			ovStealth: '208.111.48.149'

			ipsecHostname: 'honolulu.location.cypherpunk.network'
			ipsecDefault: '208.111.48.150'

			httpDefault: '208.111.48.151'
			socksDefault: '208.111.48.152'

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
