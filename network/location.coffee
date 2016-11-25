# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'

wiz.package 'cypherpunk.backend.network.location'

class cypherpunk.backend.network.location.resource extends cypherpunk.backend.network.template
	nav: true
	title: 'Locations'
	init: () =>
		super()
		@args.wizTitle = 'Manage Locations'
		@args.wizCSS = @args.wizCSS.concat(@args.wizCSSdt)
		@args.wizJS = @args.wizJS.concat(@args.wizJSdtMultiMulti)
		@args.wizBodies += 1
		@args.wizJS.push @parent.coffee('location')

# vim: foldmethod=marker wrap
