# wiz-framework: J's HTML5/NodeJS web application framework
#
# Copyright 2012 J. Maurice <j@wiz.biz>
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of version 3 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# structure:
#
# server object
#  |
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
require './middleware'
require '../util/bitmask'

wizpackage 'wiz.framework.frontend'

# node frameworks
coffee = require 'coffee-script'
connect = require 'connect'
express = require 'express'
jade = require 'jade'
fs = require 'fs'

# session storage
RedisStore = require('connect-redis')(connect)

# server config object
class wiz.framework.frontend.serverConfig
	sessionSecret : 'ChangeMeBecauseThisDefaultIsNotSecret'
	requestLimit : '2mb'

	httpHost: '0.0.0.0'
	httpPort: 10080
	httpPortActual: 80

	httpsHost: '0.0.0.0'
	httpsPort: 10443
	httpsPortActual: 443
	httpsKey: rootpath + '/ssl/wizkey.pem'
	httpsCert: rootpath + '/ssl/wizcert.pem'

class wiz.framework.frontend.powerMask
	unknown: 0
	always: 1
	public: 2
	auth: 3

class wiz.framework.frontend.powerLevel
	unknown: 0
	stranger: 1
	friend: 1001

# main server class
class wiz.framework.frontend.server

	config : new wiz.framework.frontend.serverConfig()
	powerMask : new wiz.framework.frontend.powerMask()
	powerLevel : new wiz.framework.frontend.powerLevel()

	constructor: () ->
		wizlog.notice @constructor.name, 'Server starting...'

		# create middleware structure
		@sessionRedisStore = new RedisStore()
		@middleware = new wiz.framework.frontend.middleware(@)

		# create http server for redirecting non-ssl requests to https: url
		@http = express.createServer()

		# create https server with local key/cert
		@https = express.createServer
			key: fs.readFileSync @config.httpsKey
			cert: fs.readFileSync @config.httpsCert

		# create empty module list
		@modules = {}

		# special core module and home resource
		@core = @module(new wiz.framework.frontend.module(@, '/', 'Home', @powerMask.public, @powerLevel.stranger))
		@root = @core.resource(new wiz.framework.frontend.resource(@core, '/', '', @powerMask.always, @powerLevel.stranger))

		# login and logout modules
		@login = @module(new wiz.framework.frontend.module(@, '/login', 'Login', @powerMask.public, @powerLevel.stranger))
		@logout = @module(new wiz.framework.frontend.module(@, '/logout', 'Logout', @powerMask.auth, @powerLevel.stranger))

		# public methods
		@root.method 'https', 'get', '/', @middleware.baseSession(), @handleRoot
		@root.method 'https', 'get', '/login', @middleware.baseSession(), @handleLogin
		@root.method 'https', 'post', '/postlogin', @middleware.baseSession(), @postLogin
		@root.method 'https', 'get', '/logout', @middleware.baseSession(), @handleLogout

		# for logged in users
		@root.method 'https', 'get', '/home', @middleware.baseSessionAuth(), @handleHome

	nav: (req) =>
		um = @userMask(req)
		ul = @userLevel(req)
		result = {}
		# console.log @navViews
		# console.log "User's mask: " + um.toString(2)
		for bit of @powerMask when typeof @powerMask[bit] is 'number'
			b = @powerMask[bit]
			nv = @navViews[b]
			# console.log "Checking bit: #{b}"
			if nv and wiz.framework.util.bitmask.check(um, b)
				# console.log "User matches #{b}"
				for n of nv
					# console.log "ul is #{ul}, module requires #{nv[n].level}"
					if ul >= nv[n].level
						# console.log "Adding #{n} to user's nav"
						result[n] = nv[n]
						result[n].resourceCount = 0
						result[n].resourceCount += 1 for x of nv[n].resources

		return result

	module: (mod) =>
		path = mod.path
		@modules[path] = mod
		return @modules[path]

	init: () =>
		# first, add static directories
		for module of @modules
			@modules[module].initStatic()

		# data filled in from child modules
		@viewsFolders = []
		@navViews = {}

		# then proceed to init all child modules
		for module of @modules

			# calculate views paths and add to array
			path = rootpath + @modules[module].getPath()
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
				if @modules[module].branches[resource].getTitle()
					@navViews[view][module].resources[resource] =
						title: @modules[module].branches[resource].getTitle()
						path: @modules[module].branches[resource].getPath()

		# finally, add catchall at the end
		@http.all '*', @middleware.base(), @redirect
		@https.all '*', @middleware.baseSession(), @catchall

		# Jade configuration
		@expressMultiViews express # enable multiple views directories
		@https.set 'views', @viewsFolders
		@https.set 'view engine', 'jade'
		@https.set 'view options',
			layout: false
			pretty : true

		@https.use (err, req, res, next) =>
			# pass errors to error handler
			return @error err, req, res

	expressMultiViews : (express) =>

		old = express.view.lookup

		lookup = (view, options) ->
			# If root is an array of paths, let's try each path until we find the view
			if options.root instanceof Array
				opts = {}
				for key of options
					opts[key] = options[key]
				root = opts.root
				foundView = null
				for r in root
					opts.root = r
					foundView = lookup.call(this, view, opts)
					if foundView.exists
						break
				return foundView

			# Fallback to standard behavior, when root is a single directory
			return old.call(this, view, options)

		express.view.lookup = lookup

	error: (err, req, res) =>
		wizlog.err @constructor.name, err
		res.send 500

	handleRoot: (req, res) =>
		res.send 'this is the root'

	handleHome: (req, res) =>
		res.send 'home'

	handleLogin: (req, res) =>
		res.send 'implement login here'

	postLogin : (req, res) =>
		@validateLogin req, res, (result) =>
			if result
				# login okay, do login and and redirect home
				@doLogin(req)
				@redirect(req, res, null, '/')
			else
				# login failed, redirect back to login screen
				@redirect(req, res, null, '/login?fail=1')

	# initialize all session variables
	sessionCreate: (req, res, next) =>
		req.session.wiz ?= {}
		return next() if next
		return true

	sessionDestroy: (req) =>
		req.session.wiz = {}

	sessionInit: (req, res, next) =>
		req.session.wiz.auth ?= false
		req.session.wiz.mask ?= wiz.framework.util.bitmask.set(0, @powerMask.public)
		req.session.wiz.level ?= @powerLevel.stranger
		return next() if next
		return true

	doLogin: (req) =>
		req.session.wiz.auth = true
		req.session.wiz.mask = 0
		req.session.wiz.mask = wiz.framework.util.bitmask.set(req.session.wiz.mask, @powerMask.always)
		req.session.wiz.mask = wiz.framework.util.bitmask.set(req.session.wiz.mask, @powerMask.auth)
		if req.session.wiz.level < @powerLevel.friend
			req.session.wiz.level = @powerLevel.friend

	doLogout: (req) =>
		@sessionDestroy(req)
		@sessionCreate(req)
		@sessionInit(req)

	userMask: (req) =>
		return req.session.wiz.mask ? 0

	userLevel: (req) =>
		return req.session.wiz.level ? 0

	handleLogout: (req, res) =>
		# log them out and redirect home
		wizlog.debug @constructor.name, "Logging out and redirecting..."
		@doLogout(req, res)
		@redirect(req, res, null, '/login?out=1')

	listen: () =>
		if @config.httpPort
			wizlog.warning @constructor.name, "HTTP listening on [#{@config.httpHost}]:#{@config.httpPort}"
			@http.listen @config.httpPort, @config.httpHost
		if @config.httpsPort
			wizlog.warning @constructor.name, "HTTPS listening on [#{@config.httpsHost}]:#{@config.httpsPort}"
			@https.listen @config.httpsPort, @config.httpsHost

	start: () =>
		@init()
		@listen()
		wizlog.warning @constructor.name, "Server ready!"

	redirect: (req, res, next, url = req.url, code = 303) =>
		unless @middleware.checkHostHeader req, res
			return false
		host = @host ? req.headers.host
		port = ''
		port = ":#{@config.httpsPortActual}" if @config.httpsPortActual != 443
		res.redirect "https://#{host}" + port + url, code
		return true

	catchall: (req, res) =>
		res.send 404
		return true

	# probably want to override this
	validateLogin: (req, res, cb) =>
		result = req.body.username is 'open' and req.body.password is 'sesame'
		cb result
		return

	staticContent : [
		'css'
		'img'
		'js'
	]

	staticPath: (url, disk) =>
		return unless fs.existsSync disk
		wizlog.debug @constructor.name, "adding static folder #{url} -> #{disk}"
		@https.use url, express.static(disk)

# base branch class, extended by modules/resources/methods below
class wiz.framework.frontend.branch

	constructor: (@parent, @path, @title = '', @view = 0, @level = 9000) ->
		@branches = {}
		# wizlog.debug @constructor.name, "creating #{@constructor.name} " + @getPath()
		wizassert(false, @constructor.name, "invalid @parent: #{@parent}") if not @parent or typeof @parent != 'object'
		wizassert(false, @constructor.name, "invalid @path: #{@path}") if not @path or typeof @path != 'string'

	getPath: () =>
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

	getPathSlashed: () =>
		path = @getPath()
		if path != '/'
			path = path + '/'
		return path

	getTitle : () =>
		return @title

	getLevel : () =>
		return @level

	init: () =>
		# init all resources
		for branch of @branches
			# wizlog.debug @constructor.name, "initializing #{@constructor.name} " + branch
			@branches[branch].init()

# for server modules
class wiz.framework.frontend.module extends wiz.framework.frontend.branch

	coffeeDir: '_coffee'
	coffeeExt: '.coffee'

	init: () =>
		tdir = rootpath + @getPathSlashed() + @coffeeDir
		if fs.existsSync(tdir)
			cpath = "/#{@coffeeDir}/:script#{@coffeeExt}"
			cof = new wiz.framework.frontend.method this, @parent, 'https', 'get', cpath, @parent.middleware.baseSession(), @coffeeCompile
			cof.init()
		super()

	coffee: (file) =>
		return @getPathSlashed() + @coffeeDir + '/' + file + @coffeeExt

	coffeeCompile: (req, res) =>
		res.header 'Content-Type', 'application/x-javascript'
		fn = rootpath + @getPathSlashed() + @coffeeDir + '/' + req.params.script + @coffeeExt
		fs.readFile fn, 'utf8', (err, data) ->
			if err
				wizlog.err @constructor.name, "coffee-script file not found #{fn}"
				res.send 404
				return false
			try
				js = coffee.compile data,
					bare: true
				res.send js
			catch e
				wizlog.err @constructor.name, "coffee-script compilation failed for #{fn}: #{e.toString()}"
				res.send e.toString(), 500

	resource: (res) =>
		path = res.path
		@branches[path] = res
		return @branches[path]

	initStatic: () =>
		# module-level static folders
		for staticDir in @parent.staticContent
			path = @getPathSlashed() + '_' + staticDir + '/'
			@parent.staticPath path, rootpath + path
			@initStaticDir(path, staticDir)

	initStaticDir: (path, dir) =>
		this[dir] = (file) => return path + file

# resources in a module
class wiz.framework.frontend.resource extends wiz.framework.frontend.branch

	method: (protocol, method, path, middleware, handler) =>
		@branches[path] = new wiz.framework.frontend.method this, @parent.parent, protocol, method, path, middleware, handler
		return @branches[path]

# methods in a resource
class wiz.framework.frontend.method extends wiz.framework.frontend.branch

	constructor: (@parent, @server, @protocol, @method, @path, @middleware, @handler) ->
		# wizlog.debug @constructor.name, @path
		# strip trailing / from request path
		if @path[@path.length - 1] == '/'
			@path = @path.slice(0, @path.length - 1)
		@init = () =>
			wizlog.debug @constructor.name, "adding #{@protocol} #{@method} " + @getPath()
			wizassert(false, @constructor.name, "invalid @server: #{@server}") if not @server
			@server[@protocol][@method](@getPath(), @middleware, @handler)

# vim: foldmethod=marker wrap
