# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

wiz.package 'cypherpunk.backend.api.v0.app'

class cypherpunk.backend.api.v0.app.module extends cypherpunk.backend.api.base
	database: null
	debug: true

	init: () =>
		@routeAdd new cypherpunk.backend.api.v0.app.versions(@server, this, 'versions')
		super()

class cypherpunk.backend.api.v0.app.versions extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	handler: (req, res) =>
		out =
			windows: #{{{
				required:
					code: 50
					display: '0.5.0'
				latest:
					code: 55
					display: '0.5.5'
			#}}}
			macos: #{{{
				required:
					code: 50
					display: '0.5.0'
				latest:
					code: 55
					display: '0.5.5'
			#}}}
			debian: #{{{
				required:
					code: 50
					display: '0.5.0'
				latest:
					code: 55
					display: '0.5.5'
			#}}}
			fedora: #{{{
				required:
					code: 50
					display: '0.5.0'
				latest:
					code: 55
					display: '0.5.5'
			#}}}
			android: #{{{
				required:
					code: 50
					display: '0.5.0'
				latest:
					code: 55
					display: '0.5.5'
			#}}}
			ios: #{{{
				required:
					code: 50
					display: '0.5.0'
				latest:
					code: 55
					display: '0.5.5'
			#}}}
			chrome: #{{{
				required:
					code: 50
					display: '0.5.0'
				latest:
					code: 55
					display: '0.5.5'
			#}}}
			firefox: #{{{
				required:
					code: 50
					display: '0.5.0'
				latest:
					code: 55
					display: '0.5.5'
			#}}}

		#console.log out
		res.send 200, out

# vim: foldmethod=marker wrap
