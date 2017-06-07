# wizportal web interface
# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/server/config'

wiz.package 'cypherpunk.backend.server.config'

class cypherpunk.backend.server.config extends wiz.framework.http.server.configBase

	constructor: () ->

		@sendgrid =
			apiKey: ''

		@radiusDB =
			hostname: ''
			username: ''
			password: ''
			database: 'radius'

		@smartdnsDB =
			hostname: ''
			username: ''
			password: ''
			database: 'smartdns'

		@behindReverseProxy = true

#		if wiz.hostname is 'cypherpunk-backend-dev'
#			@behindReverseProxy = true
#			@listeners[0].host = '10.111.52.113'
#			@listeners[0].port = 11080
#		else if wiz.hostname is 'wizbook3-ubuntu'
#			@listeners[0].host = '192.168.32.128'
#			@listeners[0].port = 11080
#
		if process.argv[2] == '--production'

			wiz.log.notice 'PRODUCTION STYLE'
			wiz.style = 'PRODUCTION'
			@listeners[0].port = 11080
			@mongoURI = 'mongodb://localhost:27017/cypherpunk-production'

			@amazon =
				AWSAccessKeyId: ""
				SellerId: ""
				ClientSecret: ""

			@stripe =
				apiKey: 'sk_live_'

		else if process.argv[2] == '--staging'

			wiz.log.warn 'STAGING STYLE'
			wiz.style = 'STAGING'
			@listeners[0].port = 11081
			@mongoURI = 'mongodb://localhost:27017/cypherpunk-staging'

			@amazon =
				AWSAccessKeyId: ""
				SellerId: ""
				ClientSecret: ""

			@stripe =
				apiKey: 'sk_live_'

		else if process.argv[2] == '--development'

			wiz.log.warn 'DEVELOPMENT STYLE' # 江南スタイル
			wiz.style = 'DEV'
			@listeners[0].port = 11082
			@mongoURI = 'mongodb://localhost:27017/cypherpunk-development'

			@amazon =
				AWSAccessKeyId: ""
				SellerId: ""
				ClientSecret: ""

			@stripe =
				apiKey: 'sk_test_'

		else

			console.error "Usage: #{process.argv[0]} #{process.argv[1]} --production|--development"
			process.exit(1)

		super()

# vim: foldmethod=marker wrap
