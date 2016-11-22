# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

require '../template'

wiz.package 'cypherpunk.backend.manage'

class cypherpunk.backend.manage.base extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.support
class cypherpunk.backend.manage.template extends cypherpunk.backend.template
	level: cypherpunk.backend.server.power.level.support

require './admin'
require './user'
require './affiliate'

class cypherpunk.backend.manage.module extends cypherpunk.backend.manage.base
	nav: true
	title: 'Management'

	load: () =>
		# inherit
		super()

		# static resources
		@routeAdd new wiz.framework.http.resource.coffeeFolder(@server, this, '_coffee', __dirname)
		#@routeAdd new wiz.framework.http.resource.folder(@server, this, '_css', __dirname)

		# top-level management pages
		@routeAdd new cypherpunk.backend.manage.admin.resource(@server, this, 'admin')
		@routeAdd new cypherpunk.backend.manage.user.resource(@server, this, 'users')
		@routeAdd new cypherpunk.backend.manage.affiliate.resource(@server, this, 'affiliates')

# vim: foldmethod=marker wrap
