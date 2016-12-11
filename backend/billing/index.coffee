require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

require '../template'

wiz.package 'cypherpunk.backend.billing'

class cypherpunk.backend.billing.base extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.support
class cypherpunk.backend.billing.template extends cypherpunk.backend.template
	level: cypherpunk.backend.server.power.level.support

require './subscription'
require './invoice'
require './charge'
require './receipt'
require './refund'

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
		@routeAdd new cypherpunk.backend.billing.subscription.resource(@server, this, 'subscription')
		@routeAdd new cypherpunk.backend.billing.invoice.resource(@server, this, 'invoice')
		@routeAdd new cypherpunk.backend.billing.charge.resource(@server, this, 'charge')
		@routeAdd new cypherpunk.backend.billing.receipt.resource(@server, this, 'receipt')
		@routeAdd new cypherpunk.backend.billing.refund.resource(@server, this, 'refund')

# vim: foldmethod=marker wrap
