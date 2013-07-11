# copyright 2013 wiz technologies inc.

require '..'
require '../util/strval'

require './config'
require './router'
require './csp'

http = require 'http'

wiz.package 'wiz.framework.http.server'

class wiz.framework.http.server extends wiz.base # base server object

	constructor: () -> #{{{
		super()
		@config = new wiz.framework.http.config()

		@contentSecurityPolicy = new wiz.framework.http.contentSecurityPolicy()
		@contentTypeOptions = 'nosniff'
		@frameOptions = 'sameorigin'
	#}}}

	main: () => #{{{ main server process
		# create tree trunk
		@root = new wiz.framework.http.router this, null, ''

		# create server using NodeJS built-in http module
		@server = http.createServer @handler
		# populate child branches in tree
		@init()

		# listen for requests
		@listen()
	#}}}
	init: () => #{{{
		@root.each (r) =>
			r.init()
	#}}}
	listen: () => #{{{ listen for HTTP requests according to config
		if not @config.listeners
			wiz.log.err "no listeners defined in server config!"

		for listener in @config.listeners
			wiz.log.info "HTTP listening on [#{listener.host}]:#{listener.port}"
			@server.listen listener.port, listener.host
	#}}}

	handler: (req, res, out) => #{{{
		# recursive counter for router
		req.level = 0

		# check if https or not
		req.secure = (req.connection?.encrypted? or req.headers['x-forwarded-proto'] is 'https')

		# limit request size
		req.receivedBytes = 0
		req.on 'data', (chunk) =>
			return if req.receivedBytes > @config.maxRequestLimit
			req.receivedBytes += chunk.length
			if req.receivedBytes > @config.maxRequestLimit
				wiz.log.crit "#{@getIP(req)} max request limit of #{@config.maxRequestLimit} bytes exceeded!"
				req.destroy()

		# log all requests
		res.on 'finish', () =>
			# log the result of the request
			@log req, res, out

		# utility method for sending response
		res.send = (numeric, content) =>
			res.statusCode = numeric if numeric?
			res.write(content) if content?
			res.end()

		# tell the world how awesome we are
		res.setHeader 'X-Powered-By', 'wiz-framework'

		# prevent click jacking
		res.setHeader 'X-Frame-Options', @frameOptions if @frameOptions

		# disable mime type guessing to prevent XSS
		res.setHeader 'X-Content-Type-Options', @contentTypeOptions if @contentTypeOptions

		# set security policy
		res.setHeader 'Content-Security-Policy', @contentSecurityPolicy if @contentSecurityPolicy

		# parse Host header
		return unless @parseHostHeader(req, res)

		# parse URL params
		return unless @parseURL(req, res)

		# TODO: parse req.body
		# return unless @parseBody(req, res)

		# route the request
		@router @root, req, res, out
	#}}}
	router: (parent, req, res, out) => #{{{ recursive router to handle requests

		req.level++
		sliced = req.url.split('/')
		word = sliced[req.level]
		depth = sliced.length - 1
		route = parent.routeTable[word]

		#wiz.log.debug "level #{req.level} split is #{word}"

		if route? and req.level < depth # we need to go DEEPER

			try # pass request to sub-route if we can

				#wiz.log.debug "going deeper"
				@router route, req, res, out
				return

			catch e # otherwise send 500 error

				@respond req, res, 500, e

		else if route?.handler? and (route.method is 'ANY' or route.method is req.method)

			try # handle the request if we can

				#wiz.log.debug "handling request"
				route.handler req, res, out

			catch e # otherwise send 500 error

				console.log e.stack
				@respond req, res, 500, e.toString()

		else # 404 route not found

			@respond req, res, 404, out

	#}}}
	respond: (req, res, numeric, err) => #{{{ generic http responder
		res.statusCode = numeric
		switch numeric
			when 304
				res.write 'not modified'
			when 400
				wiz.log.err "BAD REQUEST: #{err}"
				res.write err
			when 404
				res.write 'file not found'
			else
				wiz.log.err "SERVER ERROR: #{err}"
				res.write err if wiz.style is 'DEV'

		res.end()
	#}}}
	log: (req, res) => #{{{ http logger
		wiz.log.info "HTTP/#{req.httpVersion} #{res.statusCode} -> [#{@getIP(req)}] #{req.method} #{req.url} (#{req.headers['user-agent']})"
	#}}}

	parseHostHeader: (req, res) => #{{{ parse Host header
		try
			req.host = req.headers.host.split(':')[0]
		catch e
			req.host = ''

		return true if wiz.framework.util.strval.validate('fqdnDot', req.host)
		return true if wiz.framework.util.strval.validate('inet4', req.host)
		return true if wiz.framework.util.strval.validate('inet6', req.host)

		@respond req, res, 400, 'missing or invalid host header'
		return false
	#}}}
	parseURL: (req, res) => #{{{ parse url params and body
		req.params = {}

		try
			url = req.url
			qm = url.indexOf('?')
			if qm > 0 and qm < url.length
				args = url.slice(qm + 1, url.length)
				req.url = url.slice(0, qm)
				for arg in args.split('&')
					param = arg.split('=')
					x = decodeURIComponent(param[0])
					y = decodeURIComponent(param[1]) or ''
					req.params[x] = y if x? and x isnt '' and y?
		catch e
			wiz.log.err "error parsing url: #{e}"
			@respond req, res, 400, e.toString()
			return false

		return true
	#}}}
	getIP: (req) => #{{{
		ip = req.connection.remoteAddress or ''
		ip = wiz.framework.util.strval.inet6_prefix_trim ip
		return ip
	#}}}

# vim: foldmethod=marker wrap
