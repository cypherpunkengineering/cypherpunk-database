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

require './_framework/thirdparty/stripe'
require './_framework/thirdparty/sendgrid'

wiz.package 'cypherpunk.backend'

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
	level: cypherpunk.backend.server.power.level.customer
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

		# admin module
		require './admin'
		@admin = @routeAdd new cypherpunk.backend.admin.module(@server, this, 'admin')

		# init stripe SDK
		@stripe = new wiz.framework.thirdparty.stripe
			apiKey: 'sk_test_UxTTPDN0LGZaD9NBtVUxuksJ'
		@stripe.init()
		@Stripe = @stripe.Stripe

		# init sendgrid SDK
		@sendgrid = new wiz.framework.thirdparty.sendgrid
			apiKey: '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'
		@sendgrid.init()
		@SendGrid = @sendgrid.SendGrid

	#}}}
	init: () => #{{{
		super()
		#@accountDB = @api.account.database
	#}}}
	handler: (req, res) => #{{{
		@redirect(req, res, @getFullPath() + '/home')
	#}}}

# vim: foldmethod=marker wrap
