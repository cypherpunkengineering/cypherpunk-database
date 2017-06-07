# wizportal web interface
# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/server/base'
require './root'
require './power'

wiz.package 'cypherpunk.backend.server'

class cypherpunk.backend.server.csp extends wiz.framework.http.server.csp
	frame: [ "'self'", "https://*.stripe.com" ]
	img: [ "'self'" ]
	script: [ "'self'", "https://js.stripe.com", "'unsafe-inline'" ]

class cypherpunk.backend.server.main extends wiz.framework.http.server.base
	powerLevel: cypherpunk.backend.server.power.level
	powerMask: cypherpunk.backend.server.power.mask

	constructor: () ->
		super()
		@contentSecurityPolicy = new cypherpunk.backend.server.csp()

	init: () =>
		@root = new cypherpunk.backend.module(this, null, '')
		super()

		if wiz.style is 'DEV'
			wiz.sessions.select 0, (err) ->
				wiz.log.info err
		else if wiz.style is 'STAGING'
			wiz.sessions.select 1, (err) ->
				wiz.log.info err
		else if wiz.style is 'PRODUCTION'
			wiz.sessions.select 2, (err) ->
				wiz.log.info err
		else
			throw Error 'no valid redis database'

# vim: foldmethod=marker wrap
