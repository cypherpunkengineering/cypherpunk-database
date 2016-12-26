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
				latest: '0.4.0-beta'
				required: '0.3.0'
				description: 'A new version is available, please update your Cypherpunk Privacy app from https://cypherpunk.com/download'
			#}}}
			macos: #{{{
				latest: '0.4.0-beta'
				required: '0.3.0'
				description: 'A new version is available, please update your Cypherpunk Privacy app from https://cypherpunk.com/download'
			#}}}
			linux: #{{{
				latest: '0.4.0-beta'
				required: '0.3.0'
				description: 'A new version is available, please update your Cypherpunk Privacy app from https://cypherpunk.com/download'
			#}}}
			android: #{{{
				latest: 56
				required: 55
				description: 'A new version is available, please update your Cypherpunk Privacy app from Google Play.'
			#}}}
			ios: #{{{
				latest: 56
				required: 55
				description: 'A new version is available, please update your Cypherpunk Privacy app from the iTunes App store.'
			#}}}
			chrome: #{{{
				latest: 56
				required: 55
				description: 'A new version is available, please update your Cypherpunk Privacy app from the Chrome webstore.'
			#}}}
			firefox: #{{{
				latest: 56
				required: 55
				description: 'A new version is available, please update your Cypherpunk Privacy app from the Mozilla Add-ons.'
			#}}}

		#console.log out
		res.send 200, out

# vim: foldmethod=marker wrap
