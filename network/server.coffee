# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

wiz.package 'cypherpunk.backend.network.server'

class cypherpunk.backend.network.server.resource extends cypherpunk.backend.network.template
	nav: true
	title: 'Servers'
	init: () =>
		super()
		@args.wizTitle = 'Manage Privacy Servers'
		@args.wizCSS = @args.wizCSS.concat(@args.wizCSSdt)
		@args.wizJS = @args.wizJS.concat(@args.wizJSdtMultiMulti)
		@args.wizBodies += 1
		@args.wizJS.push @parent.coffee('server')

# vim: foldmethod=marker wrap
