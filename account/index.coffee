# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/acct'
require './_framework/http/resource/base'

require '../template'

require './register'
require './confirm'

wiz.package 'cypherpunk.backend.account'

class cypherpunk.backend.account.overview extends cypherpunk.backend.template
	level: cypherpunk.backend.server.power.level.friend
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.acct.session.base
	nav: false

	init: () => #{{{
		super()
		@args.wizTitle = 'Account Overview'
	#}}}

class cypherpunk.backend.account.profile extends cypherpunk.backend.template
	level: cypherpunk.backend.server.power.level.friend
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.acct.session.base
	nav: false

	init: () => #{{{
		super()
		@args.wizTitle = 'Account Profile'
		@args.wizCSS.push @parent.css('accountProfile.css')
		@args.wizJS.push @parent.parent.coffee('qr')
		@args.wizJS.push @parent.parent.coffee('qrcanvas')
		@args.wizJS.push @parent.coffee('otpAuth')
		@args.wizJS.push @parent.coffee('userProfile')
		@args.wizJS.push @parent.coffee('accountProfile')
	#}}}

class cypherpunk.backend.account.module extends wiz.framework.http.acct.module
	level: cypherpunk.backend.server.power.level.friend
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.acct.session.base
	nav: false

	load: () =>
		# inherit
		super()

		# static resources
		@routeAdd new wiz.framework.http.resource.coffeeFolder(@server, this, '_coffee', __dirname)
		@routeAdd new wiz.framework.http.resource.folder(@server, this, '_img', __dirname)
		@routeAdd new wiz.framework.http.resource.folder(@server, this, '_css', __dirname)
		@routeAdd new wiz.framework.http.resource.folder(@server, this, '_js', __dirname)

		# public account creation api
		@routeAdd new cypherpunk.backend.account.register.module(@server, this, 'register')
		# public account confirmation api
		@routeAdd new cypherpunk.backend.account.confirm.module(@server, this, 'confirm')

		# top-level my account page
		@routeAdd new cypherpunk.backend.account.overview(@server, this, 'overview')
		@routeAdd new cypherpunk.backend.account.profile(@server, this, 'profile')
		#@routeAdd new cypherpunk.backend.account.test(@server, this, 'test', 'POST')

# vim: foldmethod=marker wrap
