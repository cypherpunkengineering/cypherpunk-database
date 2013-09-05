# copyright 2013 wiz technologies inc.

require '../..'
require '../../util/list'
require './power'
require './middleware'

wiz.package 'wiz.framework.http.resource'

class wiz.framework.http.resource.base extends wiz.framework.list.tree

	middleware: [ # minimum required {{{
		wiz.framework.http.resource.middleware.parseIP
		wiz.framework.http.resource.middleware.parseHostHeader
		wiz.framework.http.resource.middleware.parseURL
		wiz.framework.http.resource.middleware.parseCookie
		wiz.framework.http.resource.middleware.parseBody
	] #}}}

	# default vars {{{
	level: wiz.framework.http.resource.power.level.unknown
	mask: wiz.framework.http.resource.power.mask.unknown
	#}}}

	constructor: (@server, @parent, @path = '', @method = 'GET') -> #{{{
		super @parent
		@method = @method.toUpperCase() if @method
		@routeTable = {}
	#}}}
	init: () => #{{{
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

		else if route?.handler? and (route.method is 'ANY' or route.method is req.method)

			try # handle the request if we can

				#wiz.log.debug "handling request"
				route.serve req, res

			catch e # otherwise send 500 error

				console.log e.stack
				res.send 500, e.toString()

		else # 404 route not found

			wiz.log.debug "no handler for this route"
			res.send 404

	#}}}
	serve: (req, res) => # {{{
		req._index_middleware = 0
		req.next = () =>
			#wiz.log.debug "req.next(): #{req._index_middleware}"
			if @middleware[req._index_middleware]
				next = @middleware[req._index_middleware]
				req._index_middleware++
				next(req, res)
			else
				process.nextTick =>
					@handler(req, res)

		req.next()
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
