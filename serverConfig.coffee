# wizportal web interface
# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/server/config'

wiz.package 'cypherpunk.backend.server.config'

class cypherpunk.backend.server.config extends wiz.framework.http.server.configBase

	constructor: () ->

		if wiz.hostname is 'cypherpunk-backend-dev'
			@behindReverseProxy = true
			@listeners[0].host = '10.111.52.113'
			@listeners[0].port = 11080
		else if wiz.hostname is 'wizbook3-ubuntu'
			@listeners[0].host = '192.168.32.128'
			@listeners[0].port = 11080

		if process.argv[2] == '--production'

			wiz.log.notice 'PRODUCTION STYLE'
			wiz.style = 'PRODUCTION'

		else if process.argv[2] == '--development'

			wiz.log.warn 'OPPA IS DEV STYLE' # 江南スタイル
			wiz.style = 'DEV'

		else

			console.error "Usage: #{process.argv[0]} #{process.argv[1]} --production|--development"
			process.exit(1)

		super()

# vim: foldmethod=marker wrap
