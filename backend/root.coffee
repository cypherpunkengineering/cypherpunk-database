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
require './_framework/thirdparty/amazon'
require './_framework/thirdparty/sendgrid'

wiz.package 'cypherpunk.backend'

require './amazon'
require './stripe'
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

		# init stripe SDK
		@stripe = new cypherpunk.backend.stripe
			apiKey: @server.config.stripe.apiKey
		@Stripe = @stripe.Stripe

		# init sendgrid SDK
		@sendgrid = new wiz.framework.thirdparty.sendgrid
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

	sendWelcomeMail: (user, cb) => #{{{
		if not user?.data?.email?
			wiz.log.err 'no user email!!'
			return

		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "welcome@cypherpunk.com"
			to:
				email: user.data.email
			#subject: 'Welcome to Cypherpunk Privacy'
			subject: 'Activate your account to get started with Cypherpunk Privacy'
			template_id: '23c0356b-cf75-470e-bced-82294688c5f7'
			substitutions:
				'-confirmUrl-': @generateConfirmationURL(user)

		@server.root.sendgrid.mailTemplate mailData, (error, response) =>
			if @debug
				console.log 'got callback from sendgrid:'
				console.log response.statusCode
				console.log response.headers
				console.log response.body
			if error
				console.log error?.response?.body?.errors
			cb()
	#}}}
	sendPurchaseMail: (user, cb) => #{{{
		if not user?.data?.email?
			wiz.log.err 'no user email!!'
			return

		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "support@cypherpunk.com"
			to:
				email: user.data.email
			subject: "You've got Premium Access to Cypherpunk Privacy"
			template_id: '43785435-e9cc-4eaf-b985-e104dcd56cb0'
			substitutions:
				'-userEmail-': user.data.email
				'-subscriptionPrice-': user.data.subscriptionPlan
				'-subscriptionRenewal-': user.data.subscriptionRenewal
				'-subscriptionExpiration-': user.data.subscriptionExpiration

		@sendMail(mailData, cb)
	#}}}
	sendUpgradeMail: (user, cb) => #{{{
		if not user?.data?.email?
			wiz.log.err 'no user email!!'
			return

		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "support@cypherpunk.com"
			to:
				email: user.data.email
			subject: "You've got Premium Access to Cypherpunk Privacy"
			template_id: '0971d5c3-5a69-40c0-b4db-54ce51acbfb4'
			substitutions:
				'-userEmail-': user.data.email
				'-subscriptionPrice-': user.data.subscriptionPlan
				'-subscriptionRenewal-': user.data.subscriptionRenewal
				'-subscriptionExpiration-': user.data.subscriptionExpiration

		wiz.log.info "Sending upgrade email to #{user.data.email}"
		@sendMail(mailData, cb)
	#}}}
	sendMail: (mailData, cb) => #{{{
		if @debug
			console.log 'send mail to sendgrid:'
			console.log mailData
		@server.root.sendgrid.mailTemplate mailData, (error, response) =>
			if @debug
				console.log 'got callback from sendgrid:'
				console.log response.statusCode
				console.log response.headers
				console.log response.body
			if error
				console.log error?.response?.body?.errors
			cb()
	#}}}
	generateConfirmationURL: (user) => #{{{
		"https://cypherpunk.com/confirm?accountId=#{user.id}&confirmationToken=#{user.confirmationToken}"
	#}}}

# vim: foldmethod=marker wrap
