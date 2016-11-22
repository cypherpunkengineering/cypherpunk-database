require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

require '../template'

wiz.package 'cypherpunk.backend.billing'

class cypherpunk.backend.billing.base extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.support
class cypherpunk.backend.billing.template extends cypherpunk.backend.template
	level: cypherpunk.backend.server.power.level.support

require './transaction'

class cypherpunk.backend.billing.module extends cypherpunk.backend.billing.base
	level: cypherpunk.backend.server.power.level.support
	nav: true
	title: 'Billing'

	load: () =>
		# inherit
		super()

		# static resources
		@routeAdd new wiz.framework.http.resource.coffeeFolder(@server, this, '_coffee', __dirname)
		#@routeAdd new wiz.framework.http.resource.folder(@server, this, '_css', __dirname)

		# top-level billingment pages
		@routeAdd new cypherpunk.backend.billing.transaction.resource(@server, this, 'transaction')

# vim: foldmethod=marker wrap
