# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../../util/list'
require './middleware'
require './power'

wiz.package 'wiz.framework.http.resource.base'

class wiz.framework.http.resource.base extends wiz.framework.list.tree

	middleware: wiz.framework.http.resource.middleware.base
	level: wiz.framework.http.resource.power.level.unknown
	mask: wiz.framework.http.resource.power.mask.unknown
	log: true
	nav: false
	debug: false

	constructor: (@server, @parent, @path = '', @method = 'GET') -> #{{{
		# XXX: not recommended to override constructor
		wiz.assert(@server, "invalid @server: #{@server}")
		wiz.assert(@parent, "invalid @parent: #{@parent}")
		super @parent
		@method = @method.toUpperCase() if @method
		@routeTable = {}
	#}}}
	load: () => #{{{ for child class
		wiz.log.debug "load #{@getFullPath()}" if @debug
	#}}}
	init: () => #{{{
		wiz.log.debug "init #{@getFullPath()}" if @debug
	#}}}

	routeAdd: (m) => #{{{
		#wiz.log.debug "added router for #{m.getFullPath()}"
		#wiz.log.debug "added handler for #{m.method} #{m.getFullPath()}" if m.handler?
		@routeTable[m.path] = m
		@branchAdd m
	#}}}

	redirect: (req, res, path = '/', numeric = 307) => #{{{ respond with a redirect to an absolute URL built from a given relative URL
		proto = (if req.secure then 'https' else 'http')

		if path and path[0..3] == 'http' # absolute url is given
			url = path
		else # relative url given, build absolute url
			url = proto + '://' + req?.headers?.host + path

		res.setHeader('Location', url)
		res.send(numeric)
	#}}}

	router: (parent, req, res) => #{{{ recursive router
		try
			# increment route depth counter
			req.routeDepth++

			# strip url parameters on ? or & delimiters
			urlStripped = req.url.split(/[\?\&]/, 1)[0]

			# split url on / delimiter
			urlSplit = urlStripped.split('/')

			# compute end depth
			urlDepth = urlSplit.length - 1

			# get current slice of url
			routeWord = urlSplit[req.routeDepth]

			# lookup word in routing table
			route = parent.routeTable[routeWord]

			#wiz.log.debug "route depth #{req.routeDepth}: word is #{routeWord}"
		catch e
			wiz.log.crit "internal router error #{e.toString()}"
			return res.send 500, "internal router error"

		if route? and req.routeDepth < urlDepth # we need to go DEEPER

			try # pass request to sub-route if we can

				#wiz.log.debug "going deeper"
				return route.router route, req, res

			catch e # otherwise send 500 error

				@handler500 req, res, e.toString()

		else if route?.handler? and
		(
			# a route for any method
			route.method is 'ANY' or
			# a route for a specific method
			route.method is req.method or
			# a route for GET should also support HEAD
			(route.method is 'GET' and req.method is 'HEAD')

		)
			try # to handle the request if we can

				#wiz.log.debug "handling request"
				req.route = route
				route.serve req, res

			catch e # otherwise send 500 error

				@handler500 req, res, e.toString()

		else if @catchall? and typeof @catchall is 'function' # catchall handler last

			req.route = this
			@serve req, res, @middleware, (req, res) =>
				@catchall(req, res, routeWord)

		else # 404 route not found

			req.route = null
			@serve req, res, wiz.framework.http.resource.middleware.minimum, (req, res) =>
				@handler404(req, res)

	#}}}

	handler: (req, res) => #{{{ default handler
		wiz.log.err 'default handler? handler not defined'
	#}}}
	handler403: (req, res) => #{{{ default 403 handler
		try
			@server.root.handler403(req, res)
		catch e
			res.send 403, 'forbidden'
	#}}}
	handler404: (req, res) => #{{{ default 404 handler
		try
			@server.root.handler404(req, res)
		catch e
			res.send 404, 'not found'
	#}}}
	handler500: (req, res, err) => #{{{ default 500 handler
		try
			@server.root.handler500(req, res, err)
		catch e
			wiz.log.err err
			res.send 500, 'server error'
	#}}}

	serve: (req, res, middleware = @middleware, handler = @handler) => # {{{
		req._index_middleware = 0
		req.next = () =>
			wiz.log.debug "req.next(): #{req._index_middleware}" if @debug
			if middleware[req._index_middleware]
				next = middleware[req._index_middleware]
				req._index_middleware++
				next(req, res, req.next)
			else
				process.nextTick =>
					wiz.assert(handler, "invalid handler for #{@getFullPath()}")
					handler(req, res)

		req.next()
	#}}}

	isAccessible: (req) => #{{{ evaluate if request can access us
		# sanity check
		return false if not req?

		#wiz.log.debug "session power level is #{req.session?.acct?.level} and required power level for #{@getFullPath()} is #{@level}"

		# err on the side of security
		return false if @level is wiz.framework.http.resource.power.level.unknown
		return false if @mask is wiz.framework.http.resource.power.level.unknown

		# don't bother checking for pages that require a session if there is no session
		return false if not req.session?.acct? and @level > wiz.framework.http.resource.power.level.stranger
		return false if not req.session?.acct? and @mask > wiz.framework.http.resource.power.mask.public

		# public pages for strangers always allowed
		if @level is wiz.framework.http.resource.power.level.stranger and
		(
			@mask is wiz.framework.http.resource.power.mask.always or
			@mask is wiz.framework.http.resource.power.mask.public
		)
			return true

		# public pages for friends require a session
		if req.session and @level is wiz.framework.http.resource.power.level.friend and
		(
			@mask is wiz.framework.http.resource.power.mask.always or
			@mask is wiz.framework.http.resource.power.mask.public
		)
			return true

		# check if session access level is greater than or equal to required access level
		return true if req.session.acct.level >= @level # TODO: check bitmask

		# default deny
		return false
	#}}}
	isVisible: (req) => #{{{ evaluate if request can access us
		return true if @isAccessible(req) and @nav is true
		return false
	#}}}

	getFullPath: () => #{{{ recurse tree back to root to obtain full path
		path = @path
		parent = @parent
		while parent
			path = parent.path + '/' + path unless (parent.path is '' and path[0] is '/')
			parent = parent.parent
		return path
	#}}}

	#{{{ file helpers
	js:		(file) => @getFullPath() + '/_js/' + file
	css:	(file) => @getFullPath() + '/_css/' + file
	coffee:	(file) => @getFullPath() + '/_coffee/' + file + '.coffee'
	img:	(file) => @getFullPath() + '/_img/' + file
	jade:	(file) => @getFullPath() + '/_jade/' + file
	#}}}

# vim: foldmethod=marker wrap
