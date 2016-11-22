# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

wiz.package 'cypherpunk.backend.manage.user'

class cypherpunk.backend.manage.user.resource extends cypherpunk.backend.manage.template
	nav: true
	title: 'Privacy Users'
	init: () =>
		super()
		@args.wizTitle = 'Manage Privacy Users'
		@args.wizCSS = @args.wizCSS.concat(@args.wizCSSdt)
		@args.wizJS = @args.wizJS.concat(@args.wizJSdtMultiMulti)
		@args.wizBodies += 1
		@args.wizJS.push @parent.coffee('user')

# vim: foldmethod=marker wrap
