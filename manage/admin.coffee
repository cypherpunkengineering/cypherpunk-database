# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

wiz.package 'cypherpunk.backend.manage.admin'

class cypherpunk.backend.manage.admin.resource extends cypherpunk.backend.manage.template
	level: cypherpunk.backend.server.power.level.executive
	nav: true
	title: 'Cypherpunk Admins'
	init: () =>
		super()
		@args.wizTitle = 'Manage Administrators'
		@args.wizCSS = @args.wizCSS.concat(@args.wizCSSdt)
		@args.wizJS = @args.wizJS.concat(@args.wizJSdtMultiMulti)
		@args.wizBodies += 1
		@args.wizJS.push @parent.coffee('admin')

# vim: foldmethod=marker wrap
