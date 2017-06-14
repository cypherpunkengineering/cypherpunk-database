# wizportal web interface
# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/resource/root'
require './_framework/http/resource/power'
require './_framework/http/resource/jade'
require './_framework/http/resource/coffee-script'
require './_framework/http/account'
require './_framework/http/account/session'

wiz.package 'cypherpunk.backend'

require './amazon'
require './bitpay'
require './paypal'
require './stripe'

require './pricing'

require './sendgrid'

require './slack'

require './template'

class cypherpunk.backend.login extends cypherpunk.backend.template
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	init: () => #{{{
		super()
		@args.wizTitle = 'login'
		@args.wizCSS.push @parent.css('login.css')
		@args.wizJS.push @parent.coffee('login')
		@file = wiz.rootpath + @parent.jade('login.jade')
	#}}}

class cypherpunk.backend.logout extends cypherpunk.backend.base
	handler: (req, res) => #{{{
		wiz.framework.http.account.session.logout(req, res)
		@redirect(req, res, @path)
	#}}}

class cypherpunk.backend.home extends cypherpunk.backend.template
	level: cypherpunk.backend.server.power.level.support
	handler: (req, res) => #{{{
		@redirect(req, res, @parent.getFullPath() + '/account/overview')
	#}}}

class cypherpunk.backend.module extends wiz.framework.http.resource.root
	load: () => #{{{
		# top-level public content
		require './public'
		@routeAdd new cypherpunk.backend.public.root(@server, this, '')
		#@routeAdd new cypherpunk.backend.public.buy(@server, this, 'buy')

		# login->home
		@routeAdd new cypherpunk.backend.home(@server, this, 'home')
		@routeAdd new cypherpunk.backend.login(@server, this, 'login')

		# static resources
		@routeAdd new wiz.framework.http.resource.coffeeFolder(@server, this, '_coffee', __dirname)
		@routeAdd new wiz.framework.http.resource.folder(@server, this, '_font', __dirname)
		@routeAdd new wiz.framework.http.resource.folder(@server, this, '_img', __dirname)
		@routeAdd new wiz.framework.http.resource.folder(@server, this, '_css', __dirname)
		@routeAdd new wiz.framework.http.resource.folder(@server, this, '_js', __dirname)

		# api module
		require './api'
		@api = @routeAdd new cypherpunk.backend.api.module(@server, this, 'api')

		# account module, based on framework classes
		require './account'
		@account = @routeAdd new cypherpunk.backend.account.module(@server, this, 'account')
		@routeAdd new cypherpunk.backend.logout(@server, this, 'logout')

		# billing module
		require './billing'
		@billing = @routeAdd new cypherpunk.backend.billing.module(@server, this, 'billing')

		# network module
		require './network'
		@network = @routeAdd new cypherpunk.backend.network.module(@server, this, 'network')

		# manage module
		require './manage'
		@manage = @routeAdd new cypherpunk.backend.manage.module(@server, this, 'manage')

		# init amazon SDK
		@amazon = new cypherpunk.backend.amazon
			AWSAccessKeyId: @server.config.amazon.AWSAccessKeyId
			SellerId: @server.config.amazon.SellerId
			ClientSecret: @server.config.amazon.ClientSecret

		# init paypal SDK
		@paypal = new cypherpunk.backend.paypal(@server, this)

		# init bitpay SDK
		@bitpay = new cypherpunk.backend.bitpay(@server, this)

		# init slack SDK
		@slack = new cypherpunk.backend.slack(@server, this)

		# init stripe SDK
		stripeArgs =
			apiKey: @server.config.stripe.apiKey
			endpointSecret: @server.config.stripe.endpointSecret
		@stripe = new cypherpunk.backend.stripe(@server, this, stripeArgs)
		@Stripe = @stripe.Stripe

		# init sendgrid SDK
		@sendgrid = new cypherpunk.backend.sendgrid
			apiKey: @server.config.sendgrid.apiKey
		@sendgrid.init()
		@SendGrid = @sendgrid.SendGrid

	#}}}
	init: () => #{{{
		super()
		@stripe.init()
		@accountDB = @api.user.database
	#}}}
	handler: (req, res) => #{{{
		@redirect(req, res, @getFullPath() + '/home')
	#}}}

# vim: foldmethod=marker wrap
