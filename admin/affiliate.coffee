# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

wiz.package 'cypherpunk.backend.admin.affiliate'

class cypherpunk.backend.admin.affiliate.resource extends cypherpunk.backend.admin.template
	nav: true
	title: 'Affiliate'
	init: () =>
		super()
		@args.wizTitle = 'Manage Affiliate'
		@args.wizCSS = @args.wizCSS.concat(@args.wizCSSdt)
		@args.wizJS = @args.wizJS.concat(@args.wizJSdtMultiMulti)
		@args.wizBodies += 1
		@args.wizJS.push @parent.coffee('affiliate')

# vim: foldmethod=marker wrap
