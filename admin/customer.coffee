# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

wiz.package 'cypherpunk.backend.admin.customer'

class cypherpunk.backend.admin.customer.resource extends cypherpunk.backend.admin.template
	nav: true
	title: 'Customers'
	init: () =>
		super()
		@args.wizTitle = 'Manage Customers'
		@args.wizCSS = @args.wizCSS.concat(@args.wizCSSdt)
		@args.wizJS = @args.wizJS.concat(@args.wizJSdtMultiMulti)
		@args.wizBodies += 1
		@args.wizJS.push @parent.coffee('customer')

# vim: foldmethod=marker wrap
