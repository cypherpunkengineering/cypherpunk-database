# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

wiz.package 'cypherpunk.backend.billing.refund'

class cypherpunk.backend.billing.refund.resource extends cypherpunk.backend.billing.template
	level: cypherpunk.backend.server.power.level.marketing
	nav: true
	title: 'Refunds'
	init: () =>
		super()
		@args.wizTitle = 'Billing Refunds'
		@args.wizCSS = @args.wizCSS.concat(@args.wizCSSdt)
		@args.wizJS = @args.wizJS.concat(@args.wizJSdtMultiMulti)
		@args.wizBodies += 1
		@args.wizJS.push @parent.coffee('refund')

# vim: foldmethod=marker wrap
