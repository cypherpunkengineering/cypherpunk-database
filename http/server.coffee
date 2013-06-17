# copyright 2013 wiz technologies inc.

require '..'
require '../util/list'
require '../util/strval'

http = require 'http'

wiz.package 'wiz.framework.http'

class wiz.framework.http.config #{{{ base server config object
	workers: 2
	maxRequestLimit: 1024 * 1024 * 2 # 2mb
	listeners: [
		{ host: '127.0.0.1', port: 11080 }
	]
#}}}

class wiz.framework.http.server extends wiz.base # base server object

	constructor: () -> #{{{
		super()
		@config = new wiz.framework.http.config()
	#}}}
	main: () => #{{{ main server process
		# create tree trunk
		@root = new wiz.framework.http.router this, null, ''

		# create server using NodeJS built-in http module
		@server = http.createServer (req, res, out) =>

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

			# tell the world how awesome we are
			res.setHeader 'X-Powered-By', 'wiz-framework'

			# parse URL params
			return unless @parseURL(req, res)

			# TODO: parse req.body

			# route the request
			req.level = 0
			@router @root, req, res, out

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
			when 404
				res.write 'file not found'
			when 500
				wiz.log.err "FAIL: #{err}"
				res.write err if wiz.style is 'DEV'

		res.end()
	#}}}
	log: (req, res) => #{{{ http logger
		wiz.log.info "HTTP/#{req.httpVersion} #{res.statusCode} -> [#{@getIP(req)}] #{req.method} #{req.url} (#{req.headers['user-agent']})"
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

class wiz.framework.http.router extends wiz.framework.list.tree

	constructor: (@server, @parent, @path = '', @method = 'GET') -> #{{{
		super @parent
		@method = @method.toUpperCase() if @method
		@routeTable = {}
	#}}}
	init: () => #{{{
		# for child class
	#}}}

	routeAdd: (m) => #{{{
		wiz.log.debug "added router for #{m.getFullPath()}"
		wiz.log.debug "added handler for #{m.method} #{m.getFullPath()}" if m.handler?
		@routeTable[m.path] = m
		@branchAdd m
	#}}}
	getFullPath: () => #{{{ recurse tree back to root to obtain full path
		path = @path
		parent = @parent
		while parent
			path = parent.path + '/' + path
			parent = parent.parent
		return path
	#}}}

# vim: foldmethod=marker wrap
