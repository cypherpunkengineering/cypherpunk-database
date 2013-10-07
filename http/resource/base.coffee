# copyright 2013 wiz technologies inc.

require '../..'
require '../../util/list'
require './power'
require './middleware'
require '../resource/power'

wiz.package 'wiz.framework.http.resource.base'

class wiz.framework.http.resource.base extends wiz.framework.list.tree

	middleware: wiz.framework.http.resource.middleware.base
	level: wiz.framework.http.resource.power.level.unknown
	mask: wiz.framework.http.resource.power.mask.unknown
	nav: false

	constructor: (@server, @parent, @path = '', @method = 'GET') -> #{{{
		# XXX: not recommended to override constructor
		wiz.assert(@server, "invalid @server: #{@server}")
		wiz.assert(@parent, "invalid @parent: #{@parent}")
		super @parent
		@method = @method.toUpperCase() if @method
		@routeTable = {}
	#}}}
	init: () => #{{{
		#wiz.log.debug "initializing #{@getFullPath()}"
		@each (r) =>
			r.init()
		# for child class
	#}}}

	routeAdd: (m) => #{{{
		#wiz.log.debug "added router for #{m.getFullPath()}"
		wiz.log.debug "added handler for #{m.method} #{m.getFullPath()}" if m.handler?
		@routeTable[m.path] = m
		@branchAdd m
	#}}}

	redirect: (req, res, path = '/', numeric = 301) => #{{{ respond with a redirect to an absolute URL built from a given relative URL
		proto = (if req.secure then 'https' else 'http')

		if path and path[0..3] == 'http' # absolute url is given
			url = path
		else # relative url given, build absolute url
			url = proto + '://' + req?.headers?.host + path

		res.setHeader('Location', url)
		res.send(numeric)
	#}}}

	router: (parent, req, res) => #{{{ recursive router
		#wiz.log.debug "router: #{req._index_route}"
		req._index_route++
		sliced = req.url.split('/')
		word = sliced[req._index_route]
		depth = sliced.length - 1
		route = parent.routeTable[word]

		#wiz.log.debug "level #{req._index_route} split is #{word}"

		if route? and req._index_route < depth # we need to go DEEPER

			try # pass request to sub-route if we can

				#wiz.log.debug "going deeper"
				route.router route, req, res
				return

			catch e # otherwise send 500 error

				res.send 500, e

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

				console.log e.stack
				res.send 500, e.toString()

		else # 404 route not found

			@serve req, res, wiz.framework.http.resource.middleware.minimum, @default

	#}}}
	default: (req, res) => #{{{ default 404 handler
		#wiz.log.debug "no handler for this route"
		res.send 404
	#}}}
	serve: (req, res, middleware = @middleware, handler = @handler) => # {{{
		req._index_middleware = 0
		req.next = () =>
			#wiz.log.debug "req.next(): #{req._index_middleware}"
			if middleware[req._index_middleware]
				next = middleware[req._index_middleware]
				req._index_middleware++
				next(req, res)
			else
				process.nextTick =>
					handler(req, res)

		req.next()
	#}}}

	isAccessible: (req) => #{{{ evaluate if request can access us
		return false if not req?
		# err on the side of security
		return false if @level is wiz.framework.http.resource.power.level.unknown
		return false if @mask is wiz.framework.http.resource.power.level.unknown

		# don't bother checking for pages that require auth if there is no session
		return false if not req.session? and @level > wiz.framework.http.resource.power.level.stranger
		return false if not req.session? and @mask > wiz.framework.http.resource.power.mask.public

		# public pages for strangers always allowed
		if @level is wiz.framework.http.resource.power.level.stranger and
		(
			@mask is wiz.framework.http.resource.power.mask.always or
			@mask is wiz.framework.http.resource.power.mask.public
		)
			return true

		# public pages for friends require a user session
		if req.session and @level is wiz.framework.http.resource.power.level.friend and
		(
			@mask is wiz.framework.http.resource.power.mask.always or
			@mask is wiz.framework.http.resource.power.mask.public
		)
			return true

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
	js: (file) =>
		return @getFullPath() + '/_js/' + file
	css: (file) =>
		return @getFullPath() + '/_css/' + file
	coffee: (file) =>
		return @getFullPath() + '/_coffee/' + file + '.coffee'
	img: (file) =>
		return @getFullPath() + '/_img/' + file
	jade: (file) =>
		return @getFullPath() + '/_jade/' + file

# vim: foldmethod=marker wrap
