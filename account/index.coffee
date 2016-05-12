# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/acct'
require './_framework/http/resource/base'

require '../template'

wiz.package 'cypherpunk.backend.account'

class cypherpunk.backend.account.resource extends cypherpunk.backend.template
	level: cypherpunk.backend.server.power.level.friend
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.acct.session.base
	nav: false

	init: () => #{{{
		super()
		@args.wizTitle = 'My Account'
		@args.wizCSS.push @parent.css('myacct.css')
		@args.wizJS.push @parent.parent.coffee('qr')
		@args.wizJS.push @parent.parent.coffee('qrcanvas')
		@args.wizJS.push @parent.coffee('otpAuth')
		@args.wizJS.push @parent.coffee('userProfile')
		@args.wizJS.push @parent.coffee('myAccount')
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
		@routeAdd new wiz.framework.http.resource.folder(@server, this, '_css', __dirname)

		# top-level my account page
		@routeAdd new cypherpunk.backend.account.resource(@server, this, 'me')

# vim: foldmethod=marker wrap
