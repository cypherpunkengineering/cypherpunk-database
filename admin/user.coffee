# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/acct'
require './_framework/http/resource/base'

wiz.package 'cypherpunk.backend.admin.user'

class cypherpunk.backend.admin.user.resource extends cypherpunk.backend.admin.template
	nav: true
	title: 'Users'
	init: () =>
		super()
		@args.wizTitle = 'Manage Users'
		@args.wizCSS = @args.wizCSS.concat(@args.wizCSSdt)
		@args.wizJS = @args.wizJS.concat(@args.wizJSdtMultiMulti)
		@args.wizBodies += 1
		@args.wizJS.push @parent.coffee('user')

# vim: foldmethod=marker wrap
