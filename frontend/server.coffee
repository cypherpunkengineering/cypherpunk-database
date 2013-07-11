# copyright 2013 wiz technologies inc.
#
# server object
#  |
#  |-- /module1
#  |    |
#  |    |-- /module1/resource1
#  |    |    |
#  |    |    |-- /module1/resource1/method1
#  |    |    `-- /module1/resource1/method2
#  |    |
#  |    `-- /module1/resource2
#  |         |
#  |         |-- /module1/resource2/method1
#  |         `-- /module1/resource2/method2
#  |
#  `-- /module2
#       |
#       |-- /module2/resource1
#       |    |
#       |    |-- /module2/resource1/method1
#       |    `-- /module2/resource1/method2
#       |
#       `-- /module2/resource2
#            |
#            |-- /module2/resource2/method1
#            `-- /module2/resource2/method2
#
require '..'
require './database'

wiz.package 'wiz.framework.frontend'

# node frameworks
coffee = require 'coffee-script'
cluster = require 'cluster'
http = require 'http'
jade = require 'jade'
fs = require 'fs'
os = require 'os'

class wiz.framework.frontend.config #{{{ base server config object
	hostname: os.hostname()
	httpHost: '127.0.0.1'
	httpPort: 10080
	httpPortActual: 10080
	workers: 2
#}}}

class wiz.framework.frontend.server # base server object

	constructor: () -> #{{{
		@config = new wiz.framework.frontend.config()
	#}}}
	start: () => #{{{ main process
		@master() if cluster.isMaster
		@worker() if cluster.isWorker
	#}}}
	master: () => #{{{ main process of master supervisor process
		wiz.log.notice "*** MASTER #{process.pid} START"

		cluster.on 'exit', (worker, code, signal) ->
			wiz.log.crit "WORKER #{worker.process.pid} DIED! (SIGNAL #{code})"
			setTimeout cluster.fork, 500

		for i in [1..@config.workers]
			cluster.fork()
	#}}}
	worker: () => #{{{ main process of forked worker processes
		wiz.log.notice "*** WORKER #{process.pid} START"
		@preModuleCreate()
		@moduleCreate()
		@moduleInit()
		@postModuleInit()
		@listen()
	#}}}

	preModuleCreate: () => #{{{ called before modules are created and initialized
		# implement in child class
	#}}}
	postModuleInit: () => #{{{ called after modules are created and initialized
	#}}}
	moduleCreate: () => #{{{ create modules
		# for child class use
	#}}}
	moduleInit: () => #{{{ initialize modules

		# first, add static directories
		for module of @modules
			@modules[module].initStatic()

		# data filled in from child modules
		@viewsFolders = []
		@navViews = {}

		# then proceed to init all child modules
		for module of @modules

			# calculate views paths and add to array
			path = wiz.rootpath + @modules[module].getPath()
			if path.length > 1 and path[path.length - 1] != '/'
				path = path + '/'
			path = path + 'views'
			@viewsFolders.push(path)

			# do normal init
			@modules[module].init()

			# add nav tree for given view
			view = @modules[module].view
			@navViews[view] ?= {}
			@navViews[view][module] =
				title: @modules[module].getTitle()
				path: @modules[module].getPath()
				level: @modules[module].getLevel()
				resources: {}
			for resource of @modules[module].branches
				if @modules[module].branches[resource].getTitle and @modules[module].branches[resource].getTitle()
					@navViews[view][module].resources[resource] =
						title: @modules[module].branches[resource].getTitle()
						path: @modules[module].branches[resource].getPath()
						level: @modules[module].branches[resource].getLevel()
	#}}}
	listen: () => #{{{ listen for HTTP requests according to config
	#}}}

	error: (err, req, res, code) => #{{{ middleware error handler
		wiz.log.err err
		return false unless res
		return res.send err, code if code
		return res.send 500
	#}}}
	redirectToRoot: (req, res) => #{{{ middleware redirect to /
		@redirect req, res, null, '/'
	#}}}
	redirect: (req, res, next, url = req.url, numeric = 303) => #{{{ middleware redirect
		return false unless @middleware.checkHostHeader req, res
		host = req.headers.host ? ''
		host = host.split(':')[0] if host.indexOf ':' != -1
		host += ":#{@config.httpPortActual}" if @config.httpPortActual != 443
		target = 'https://' + host + url
		res.redirect target, numeric
		return true
	#}}}
	catchall: (req, res) => #{{{ middleware catchall 404 response
		res.send 404
		return true
	#}}}

	module: (mod) => #{{{ add a module
		path = mod.path
		@modules[path] = mod
		return @modules[path]
	#}}}

class wiz.framework.frontend.branch # base branch class, extended by modules/resources/methods below

	constructor: (@server, @parent, @path, @title = '', @view = 0, @level = 9000) -> #{{{
		@branches = {}
		# wiz.log.debug "creating #{@constructor.name} " + @getPath()
		wiz.assert(false, "invalid @parent: #{@parent}") if not @parent or typeof @parent != 'object'
		wiz.assert(false, "invalid @path: #{@path}") if not @path or typeof @path != 'string'
	#}}}

	getPath: () => #{{{ get assigned path of a branch
		return @path if @path[0..3] == 'http'

		if not @parent or not @parent.getPath # if top-level

			path = @path

		else # not top-level

			path = @parent.getPath() # start with parent path

			# don't append extra leading slash for root module
			if path == '/' and @path[0] == '/'
				path = @path
			else
				path = path + @path

		# if not present, add leading slash
		if path[0] != '/'
			path = '/' + path

		return path
	#}}}
	getPathSlashed: () => #{{{ get assigned path with leading slash
		path = @getPath()
		if path != '/'
			path = path + '/'
		return path
	#}}}

	getTitle : () => #{{{
		return @title
	#}}}
	getLevel : () => #{{{
		return @level
	#}}}
	getMask : () => #{{{
		return @mask
	#}}}

	init: () => #{{{ initialize the branch
		# init all resources
		for branch of @branches
			# wiz.log.debug "initializing #{@constructor.name} " + branch
			if @branches[branch] instanceof Array
				b.init() for b in @branches[branch]
			else
				@branches[branch].init()
	#}}}

class wiz.framework.frontend.module extends wiz.framework.frontend.branch # for server modules

	#{{{ coffee settings
	coffeeDir: '_coffee'
	coffeeExt: '.coffee'
	#}}}

	init: () => #{{{ initializes the module
		tdir = wiz.rootpath + @getPathSlashed() + @coffeeDir
		if fs.existsSync(tdir)
			cpath = "/#{@coffeeDir}/:script#{@coffeeExt}"
			cof = new wiz.framework.frontend.method @parent, this, 'get', cpath, @parent.middleware.baseSession(), @server.powerMask.always, @server.powerLevel.stranger, @coffeeCompile
			cof.init()
		super()
	#}}}

	coffee: (file) => #{{{ returns path to a coffee script file
		return @getPathSlashed() + @coffeeDir + '/' + file + @coffeeExt
	#}}}
	coffeeCompile: (req, res) => #{{{ compiles coffeescript on the fly
		res.header 'Content-Type', 'application/x-javascript'
		fn = wiz.rootpath + @getPathSlashed() + @coffeeDir + '/' + req.params.script + @coffeeExt
		fs.readFile fn, 'utf8', (err, data) ->
			if err
				wiz.log.err "coffee-script file not found #{fn}"
				res.send 404
				return false
			try
				js = coffee.compile data,
					bare: true
				res.send js
			catch e
				wiz.log.err "coffee-script compilation failed for #{fn}: #{e.toString()}"
				res.send e.toString(), 500
	#}}}

	resource: (res) => #{{{ adds a resource
		path = res.path
		@branches[path] = res
		return @branches[path]
	#}}}

	initStatic: () => #{{{ initializes static folders if present in the module
		# module-level static folders
		for staticDir in @parent.staticContent
			path = @getPathSlashed() + '_' + staticDir + '/'
			@parent.staticPath path, wiz.rootpath + path
			@initStaticDir(path, staticDir)

		for staticDir in @parent.cdnContent
			path = @getPathSlashed() + staticDir + '/'
			@parent.staticPath path, wiz.rootpath + path, true
	#}}}
	initStaticDir: (path, dir) => #{{{ initializes a given static folder path
		this[dir] = (file) => return path + file
	#}}}

	method: (method, path, middleware, powerMask, powerLevel, handler) => #{{{ adds a method to a module
		@branches[path] ?= []
		@branches[path].push(new wiz.framework.frontend.method(@parent, this, method, path, middleware, powerMask, powerLevel, handler))
		return @branches[path]
	#}}}

class wiz.framework.frontend.resource extends wiz.framework.frontend.branch # resources in a module

	method: (method, path, middleware, powerMask, powerLevel, handler) => #{{{ adds a method to a resource
		@branches[path] ?= []
		@branches[path].push(new wiz.framework.frontend.method(@parent.parent, this, method, path, middleware, powerMask, powerLevel, handler))
		return @branches[path]
	#}}}

class wiz.framework.frontend.method extends wiz.framework.frontend.branch # methods in a resource

	constructor: (@server, @parent, @method, @path, @middleware, @mask, @level, @handler) -> #{{{
		# wiz.log.debug @path
		# strip trailing / from request path
		if @path[@path.length - 1] == '/'
			@path = @path.slice(0, @path.length - 1)
		@init = () =>
			# wiz.log.debug "adding #{@method} " + @getPath()
			wiz.assert(false, "invalid @server: #{@server}") if not @server
			@server.http[@method](@getPath(), @middleware, (req, res) =>
				# wiz.log.debug "#{@server.userLevel(req)} and #{@getLevel()}"
				return res.send 404 unless @server.userLevel(req) >= @getLevel()
				req.wizMethodLevel = @getLevel()
				req.wizMethodMask = @getMask()
				req.wizMethodPublic = req.wizMethodMask < @server.powerMask.auth and req.wizMethodLevel < @server.powerLevel.friend
				@handler req, res
			)
	#}}}

# vim: foldmethod=marker wrap
