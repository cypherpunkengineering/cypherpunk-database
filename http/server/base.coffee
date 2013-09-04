# copyright 2013 wiz technologies inc.

require '../..'
require '../../util/list'

require '../resource/base'
require './config'
require './csp'

http = require 'http'

wiz.package 'wiz.framework.http.server.base'

class wiz.framework.http.server.base extends wiz.base # base http server object

	constructor: () -> #{{{
		super()
		@config = new wiz.framework.http.server.config()

		@contentSecurityPolicy = new wiz.framework.http.server.csp()
		@contentTypeOptions = 'nosniff'
		@frameOptions = 'sameorigin'
	#}}}

	main: () => #{{{ main server process
		# create tree trunk
		@root = new wiz.framework.http.resource.base this, null, ''

		# NodeJS built-in http server, wiz framework router
		@server = http.createServer @handler

		# app-side initialization
		@init()

		# populate child branches in tree
		@root.each (r) =>
			r.init()

		# listen for requests
		@listen()
	#}}}
	init: () => # for app-side initialization {{{
	#}}}
	listen: () => #{{{ listen for HTTP requests according to config
		if not @config.listeners
			wiz.log.err "no listeners defined in server config!"

		for listener in @config.listeners
			wiz.log.info "HTTP listening on [#{listener.host}]:#{listener.port}"
			@server.listen listener.port, listener.host
	#}}}
	handler: (req, res, out) => # HTTP request handler {{{
		# recursive counter for router
		req._index_route = 0

		# check if https or not
		req.secure = (req.connection?.encrypted? or req.headers['x-forwarded-proto'] is 'https')

		# limit request size
		req.receivedBytes = 0
		req.on 'data', (chunk) =>
			return if req.receivedBytes > @config.maxRequestLimit
			req.receivedBytes += chunk.length
			if req.receivedBytes > @config.maxRequestLimit
				wiz.log.crit "#{req.ip} max request limit of #{@config.maxRequestLimit} bytes exceeded!"
				req.destroy()

		# log all requests
		res.on 'finish', () =>
			# save session, set cookie header
			wiz.framework.http.account.session.save(req.session) if req.session?.sid?

			# log the result of the request
			@log req, res, out

		# utility method for sending response
		res.send = (numeric = 200, content = null, err = null) =>

			if content and typeof content is 'object'
				content = JSON.stringify(content)
				res.setHeader 'Content-type', 'application/json'
				res.setHeader 'Content-length', content.length

			err ?= content ? 'unknown error'

			res.statusCode = numeric

			switch numeric
				when 100, 101
					res.write(content) if content?
				when 304
					res.write 'not modified'
					res.end()
				when 400
					wiz.log.err "BAD REQUEST: #{err}"
					res.write err.toString() if wiz.style is 'DEV'
					res.end()
				when 404
					res.write 'file not found'
					res.end()
				when 500, 501, 502, 503, 504, 505
					wiz.log.err "SERVER ERROR: #{err}"
					res.write err.toString() if wiz.style is 'DEV'
					res.end()
				else
					res.write(content) if content?
					res.end()

		# prevent click jacking
		res.setHeader 'X-Frame-Options', @frameOptions if @frameOptions

		# disable mime type guessing to prevent XSS
		res.setHeader 'X-Content-Type-Options', @contentTypeOptions if @contentTypeOptions

		# set security policy
		res.setHeader 'Content-Security-Policy', @contentSecurityPolicy if @contentSecurityPolicy

		# pass to root resource router
		@root.router @root, req, res
	#}}}

	log: (req, res) => #{{{ http logger
		wiz.log.info "HTTP/#{req.httpVersion} #{res.statusCode} -> [#{req.ip}] #{req.method} #{req.url} (#{req.headers['user-agent']})"
	#}}}

# vim: foldmethod=marker wrap
