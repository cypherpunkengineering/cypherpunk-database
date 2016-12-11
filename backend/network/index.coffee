# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

require '../template'

wiz.package 'cypherpunk.backend.network'

class cypherpunk.backend.network.base extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.engineer
class cypherpunk.backend.network.template extends cypherpunk.backend.template
	level: cypherpunk.backend.server.power.level.engineer

require './location'
require './server'

class cypherpunk.backend.network.module extends cypherpunk.backend.network.base
	nav: true
	title: 'Network'

	load: () =>
		# inherit
		super()

		# static resources
		@routeAdd new wiz.framework.http.resource.coffeeFolder(@server, this, '_coffee', __dirname)
		#@routeAdd new wiz.framework.http.resource.folder(@server, this, '_css', __dirname)

		# top-level networkment pages
		@routeAdd new cypherpunk.backend.network.location.resource(@server, this, 'locations')
		@routeAdd new cypherpunk.backend.network.server.resource(@server, this, 'servers')

# vim: foldmethod=marker wrap
