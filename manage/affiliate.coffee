# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

wiz.package 'cypherpunk.backend.manage.affiliate'

class cypherpunk.backend.manage.affiliate.resource extends cypherpunk.backend.manage.template
	level: cypherpunk.backend.server.power.level.marketing
	nav: true
	title: 'Affiliates'
	init: () =>
		super()
		@args.wizTitle = 'Manage Affiliate Accounts'
		@args.wizCSS = @args.wizCSS.concat(@args.wizCSSdt)
		@args.wizJS = @args.wizJS.concat(@args.wizJSdtMultiMulti)
		@args.wizBodies += 1
		@args.wizJS.push @parent.coffee('affiliate')

# vim: foldmethod=marker wrap
