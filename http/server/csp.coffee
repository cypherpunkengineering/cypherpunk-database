# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'

wiz.package 'wiz.framework.http.server.csp'

class wiz.framework.http.server.csp # HTTP Content-Security-Policy header
	# ref: http://www.html5rocks.com/en/tutorials/security/content-security-policy/

	# define defaults for any directive left undefined
	default: [ "'self'" ]

	# limits the origins to which you can connect (XHR/WebSockets/EventSource)
	connect: undefined

	# specifies the origins that can serve web fonts
	font: undefined

	# lists the origins that can be embedded as frames
	frame: [ "'none'" ]

	# allow inline styles
	style: [ "'self'", "'unsafe-inline'" ]

	# defines the origins from which images can be loaded
	img: undefined

	# restricts the origins allowed to deliver video and audio
	media: undefined

	# allows control over Flash and other plugins
	object: [ "'none'" ]

	constructor: (https = false) ->
		@default.unshift('https:') if https

	# print policy as a string for use in HTTP header
	toString: () =>
		# "default-src https: 'self'; frame-src 'none'; object-src 'none'"
		policies = []
		for directive of this when this[directive] instanceof Array
			policies.push directive + '-src ' + this[directive].join(' ')
		policyStr = policies.join('; ')
		#wiz.log.debug policyStr
		return policyStr

# vim: foldmethod=marker wrap
