# wizportal web interface
# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/server/base'
require './root'
require './power'

wiz.package 'cypherpunk.backend.server'

class cypherpunk.backend.server.csp extends wiz.framework.http.server.csp
	frame: [ "'self'" ]
	img: [ "'self'" ]

class cypherpunk.backend.server.main extends wiz.framework.http.server.base
	powerLevel: cypherpunk.backend.server.power.level
	powerMask: cypherpunk.backend.server.power.mask

	constructor: () ->
		super()
		@contentSecurityPolicy = new cypherpunk.backend.server.csp()

	init: () =>
		@root = new cypherpunk.backend.module(this, null, '')
		super()

# vim: foldmethod=marker wrap
