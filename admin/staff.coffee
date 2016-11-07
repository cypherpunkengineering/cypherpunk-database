# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

wiz.package 'cypherpunk.backend.admin.staff'

class cypherpunk.backend.admin.staff.resource extends cypherpunk.backend.admin.template
	nav: true
	title: 'Staff'
	init: () =>
		super()
		@args.wizTitle = 'Manage Staff'
		@args.wizCSS = @args.wizCSS.concat(@args.wizCSSdt)
		@args.wizJS = @args.wizJS.concat(@args.wizJSdtMultiMulti)
		@args.wizBodies += 1
		@args.wizJS.push @parent.coffee('staff')

# vim: foldmethod=marker wrap
