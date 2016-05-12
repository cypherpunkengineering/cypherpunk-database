# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/acct'
require './_framework/http/resource/base'

require '../template'

wiz.package 'cypherpunk.backend.admin'

class cypherpunk.backend.admin.base extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.support
class cypherpunk.backend.admin.template extends cypherpunk.backend.template
	level: cypherpunk.backend.server.power.level.support

require './user'

class cypherpunk.backend.admin.module extends cypherpunk.backend.admin.base
	nav: true
	title: 'Administration'

	load: () =>
		# inherit
		super()

		# static resources
		@routeAdd new wiz.framework.http.resource.coffeeFolder(@server, this, '_coffee', __dirname)
		#@routeAdd new wiz.framework.http.resource.folder(@server, this, '_css', __dirname)

		# top-level management pages
		@routeAdd new cypherpunk.backend.admin.user.resource(@server, this, 'users')

# vim: foldmethod=marker wrap
