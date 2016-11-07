# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../../util/list'

require '../base'
require '../resource/base'
require '../account/session'
require './config'
require './csp'

http = require 'http'

wiz.package 'wiz.framework.http.server.base'

class wiz.framework.http.server.base extends wiz.framework.http.base
	constructor: () -> #{{{
		super()
		@config = new wiz.framework.http.server.configBase()

		@contentSecurityPolicy = new wiz.framework.http.server.csp()
		@contentTypeOptions = 'nosniff'
		@frameOptions = 'sameorigin'
	#}}}

	main: () => #{{{ main server process
		# NodeJS built-in http server, wiz framework router
		@server = http.createServer(@handler)

		# app-side initialization
		setTimeout @init, 200

		# listen for requests
		setTimeout @listen, 2000

	#}}}
	init: () => # for app-side initialization {{{
		wiz.log.crit 'root resource is missing!' unless @root
		@powerLevel ?= new wiz.framework.http.resource.power.level()
		@powerMask ?= new wiz.framework.http.resource.power.mask()
		@root.load()
		@root.init()
	#}}}
	listen: () => # listen for HTTP requests according to config {{{
		if not @config.listeners
			wiz.log.err "no listeners defined in server config!"

		for listener in @config.listeners
			wiz.log.info "HTTP listening on [#{listener.host}]:#{listener.port}"
			@server.listen listener.port, listener.host
	#}}}
	handler: (req, res, out) => # HTTP request handler {{{

		#{{{ request setup
		# allow req to reference us if necessary
		req.server = this

		# limit request size
		req.receivedBytes = 0

		# recursive counter for router
		req.routeDepth = 0

		# default accept ct is text
		req.headers.accept ?= [ 'text/plain' ]

		# check if https or not
		if @config.behindReverseProxy is true
			req.secure = (req.headers['x-forwarded-proto'] is 'https')
		else
			req.secure = req.connection?.encrypted?
		#}}}
		req.on 'data', (chunk) => #{{{ limit request size
			return if req.receivedBytes > @config.maxRequestLimit
			req.receivedBytes += chunk.length
			if req.receivedBytes > @config.maxRequestLimit
				wiz.log.crit "#{req.ip} max request limit of #{@config.maxRequestLimit} bytes exceeded!"
				req.destroy()
		#}}}
		req.is = (ct) => #{{{ accept header utility matcher
			return ~req.headers.accept.indexOf(ct)
		#}}}

		#{{{ response setup
		# prevent click jacking
		res.setHeader 'X-Frame-Options', @frameOptions if @frameOptions

		# disable mime type guessing to prevent XSS
		res.setHeader 'X-Content-Type-Options', @contentTypeOptions if @contentTypeOptions

		# set security policy
		res.setHeader 'Content-Security-Policy', @contentSecurityPolicy if @contentSecurityPolicy

		# close connection
		res.setHeader 'Connection', 'close'
		#}}}
		res.setCookie = (opts) => #{{{
			# Set-Cookie: connect.sid=RBYBtQ8XYmaX9fr9DPcfKhUy.vzR8ey26fYG7sGJYHHUSzSWyJJO12e5jiW0BKdd3YsY; path=/; expires=Sun, 08 Sep 2013 14:03:51 GMT; httpOnly; secure
			pairs = [opts.name + '=' + encodeURIComponent(opts.val)]
			pairs.push 'expires=' + opts.expires.toUTCString() if opts.expires
			pairs.push 'domain=' + opts.domain if opts.domain
			pairs.push 'path=' + (opts.path or '/')
			pairs.push 'httpOnly' unless opts.httpOnly is false
			pairs.push 'secure' if req.secure

			cookie = pairs.join('; ')

			#wiz.log.debug "sending cookie: #{cookie}"
			res.setHeader 'Set-Cookie', cookie
		#}}}
		res.send = (numeric = 200, content = '', err = null) => #{{{ for sending response
			if res.alreadySent
				wiz.log.crit '******* response already sent!'
				return

			# set numeric
			res.statusCode = numeric

			# error responses
			if numeric >= 400
				if err
					# log error if present
					wiz.log.err "#{numeric} - #{err}"

					# include stacktrace or error msg if development mode
					content += err.toString() if wiz.style is 'DEV'

			# if our content is more than just ''
			if !!content

				# send buffer as-is
				if content instanceof Buffer
					# buffer length is byte length
					len = content.length

				# send string as-is
				else if typeof content is 'string'
					# content-length should be byte length of string, not character length
					len = Buffer.byteLength(content)

				# send object as requested by Accept: header
				else if typeof content is 'object'

					if req.is('application/json') or req.is('*/*')

						# set json ct
						if not res.getHeader 'Content-Type'
							res.setHeader 'Content-Type', 'application/json'

						# stringify object as JSON
						content = JSON.stringify(content)

					else if req.is 'text/plain' # default

						# set text ct
						res.setHeader 'Content-Type', 'text/plain'

						# pretty print json
						content = JSON.stringify(content, null, '\t')

					# TODO: implement other content types
					else # If an Accept header field is present, and if the server cannot send a response which is acceptable according to the combined Accept field value, then the server SHOULD send a 406 (not acceptable) response.

						res.statusCode = 406
						len = undefined
						content = ''

				if req.method isnt 'HEAD'
					res.setHeader 'Content-Length', len if len?
					res.write content

			res.end() unless numeric < 200
			res.alreadySent = true
		#}}}
		res.on 'finish', () => #{{{ log all requests
			# TODO: implement post-response-middleware
			# save session, set cookie header
			wiz.framework.http.account.session.save(req)

			# log the result of the request
			@log req, res, out unless res?.route?.log is false
		#}}}

		# pass to root resource router
		@root.router @root, req, res
	#}}}

	log: (req, res) => #{{{ http logger
		wiz.log.info "[#{req.ip}] \"#{req.method} #{req.url} HTTP/#{req.httpVersion}\" #{res.statusCode} #{res.getHeader('Content-Length') or '-'} #{req.headers?['referrer'] or '-'} \"#{req.headers['user-agent']}\""
	#}}}

# vim: foldmethod=marker wrap
