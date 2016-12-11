# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

wiz.package 'cypherpunk.backend.billing.subscription'

class cypherpunk.backend.billing.subscription.resource extends cypherpunk.backend.billing.template
	level: cypherpunk.backend.server.power.level.marketing
	nav: true
	title: 'Subscriptions'
	init: () =>
		super()
		@args.wizTitle = 'Billing Subscriptions'
		@args.wizCSS = @args.wizCSS.concat(@args.wizCSSdt)
		@args.wizJS = @args.wizJS.concat(@args.wizJSdtMultiMulti)
		@args.wizBodies += 1
		@args.wizJS.push @parent.coffee('subscription')

# vim: foldmethod=marker wrap
