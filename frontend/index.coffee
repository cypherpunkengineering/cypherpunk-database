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

wiz.package 'wiz.framework.frontend'

# node frameworks
coffee = require 'coffee-script'
connect = require 'connect'
cluster = require 'cluster'
express = require 'express'
jade = require 'jade'
fs = require 'fs'
os = require 'os'

# riak driver
riak = require '../_deps/riak-js'
RiakStore = require('../_deps/connect-riak')(express)

# server config object
class wiz.framework.frontend.serverConfig
	sessionSecret : 'ChangeMeBecauseThisDefaultIsNotSecret'
	requestLimit : '2mb'
	riak: {}

	httpHost: '0.0.0.0'
	httpPort: 10080
	httpPortActual: 80

	httpsHost: '0.0.0.0'
	httpsPort: 10443
	httpsPortActual: 443

	favicon: ''

	express:
		key: ''
		cert: ''
		ca: ''

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

	master: () =>
		wiz.log.notice "*** MASTER #{process.pid} START"

		cluster.on 'exit', (worker, code, signal) ->
			wiz.log.crit "WORKER #{worker.process.pid} DIED! (SIGNAL #{code})"
			setTimeout cluster.fork, 500

		for i in [1..2]
			cluster.fork()

	worker: () =>
		wiz.log.notice "*** WORKER #{process.pid} START"

		# create middleware structure
		@sessionStore = new @createSessionStore()
		@middleware = new wiz.framework.frontend.middleware(@)

		# create http server for redirecting non-ssl requests to https: url
		@http = express.createServer()

		# create https server with local key/cert
		if @config.express
			@https = express.createServer @config.express
		else
			@https = express.createServer()

		for b in @middleware.base()
			@http.use b
			@https.use b

		@https.use express.favicon @config.favicon

		# create empty module list
		@modules = {}

		# special core module and home resource
		@core = @module(new wiz.framework.frontend.module(@, @, '/', 'Home', @powerMask.public, @powerLevel.stranger))
		@root = @core.resource(new wiz.framework.frontend.resource(@, @core, '/', '', @powerMask.always, @powerLevel.stranger))

		# login and logout modules
		@login = @module(new wiz.framework.frontend.module(@, @, '/login', null, @powerMask.public, @powerLevel.stranger))
		@logout = @module(new wiz.framework.frontend.module(@, @, '/logout', null, @powerMask.auth, @powerLevel.stranger))

		# public methods
		@root.method 'https', 'get', '/', @middleware.baseSession(), @powerMask.always, @powerLevel.stranger, @handleRoot
		@root.method 'https', 'get', '/login', @middleware.baseSession(), @powerMask.always, @powerLevel.stranger, @getLogin
		@root.method 'https', 'post', '/login', @middleware.baseSession(), @powerMask.always, @powerLevel.stranger, @postLogin
		@root.method 'https', 'get', '/logout', @middleware.baseSession(), @powerMask.always, @powerLevel.stranger, @getLogout
		@root.method 'https', 'post', '/logout', @middleware.baseSession(), @powerMask.always, @powerLevel.stranger, @postLogout

		# for logged in users
		@root.method 'https', 'get', '/home', @middleware.baseSessionAuth(), @powerMask.always, @powerLevel.stranger, @handleHome

		# init
		@preinit()
		@init()
		@listen()

	createSessionStore: () =>
		return new RiakStore @config.riak

	nav: (req) =>
		um = @userMask req
		ul = @userLevel req
		result = {}
		# console.log @navViews
		# console.log "User's mask: " + um.toString(2)

		if req.wizMethodPublic
			@navView result, ul, @navViews[@powerMask.public]
			@navView result, ul, @navViews[@powerMask.always]
		else
			for bit of @powerMask when typeof @powerMask[bit] is 'number'
				b = @powerMask[bit]
				nv = @navViews[b]
				# console.log "Checking bit: #{b}"
				if nv and wiz.framework.util.bitmask.check(um, b)
					# console.log "User matches #{b}"
					@navView result, ul, nv

		return result

	navView: (result, ul, nv) =>
		for n of nv
			# console.log "ul is #{ul}, module requires #{nv[n].level}"
			if ul >= nv[n].level
				# console.log "Adding #{n} to user's nav"
				result[n] = {}
				result[n].resourceCount = 0
				for x of nv[n]
					if x isnt 'resources'
						result[n][x] = nv[n][x]
					else
						result[n][x] = {}
						for r of nv[n][x] when resource = nv[n][x][r]
							# console.log resource
							if ul >= resource.level
								# console.log "adding #{resource.path}"
								result[n][x][r] = resource
								result[n].resourceCount += 1

	module: (mod) =>
		path = mod.path
		@modules[path] = mod
		return @modules[path]

	preinit: () =>
		# implement in child class

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
						level: @modules[module].branches[resource].getLevel()

		# finally, add catchall at the end
		@http.all '*', @redirect
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

	error: (err, req, res, code) =>
		wiz.log.err err
		return false unless res
		return res.send err, code if code
		return res.send 500

	handleRoot: (req, res) =>
		res.send 'this is the root'

	handleHome: (req, res) =>
		res.send 'home'

	getLogin: (req, res) =>
		res.send 'login page'
		# implement a login page in child class

	postLogin : (req, res) =>
		@validateLogin req, res, (err, ok) =>
			if err
				wiz.log.err "login failed: #{err}"
				res.send err, 400
				return

			# login okay, do login and and redirect home
			@doLogin req if ok
			res.send 200

	getLogout: (req, res) =>
		# log them out and redirect home
		wiz.log.debug "Logging out, sending redirect"
		@doLogout req, res
		@redirectToRoot req, res

	redirectToRoot: (req, res) =>
		@redirect req, res, null, '/'

	postLogout: (req, res) =>
		# log them out and redirect home
		wiz.log.debug "Logging out, sending 200 OK"
		@doLogout req, res
		res.send 200

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
		req.session.wiz.mask = wiz.framework.util.bitmask.set req.session.wiz.mask, @powerMask.always
		req.session.wiz.mask = wiz.framework.util.bitmask.set req.session.wiz.mask, @powerMask.auth
		if req.session.wiz.level < @powerLevel.friend
			req.session.wiz.level = @powerLevel.friend

	doLogout: (req) =>
		@sessionDestroy req
		@sessionCreate req

	userMask: (req) =>
		return 0 if not req.session or not req.session.wiz
		return req.session.wiz.mask ? 0

	userLevel: (req) =>
		return 0 if not req.session or not req.session.wiz
		return req.session.wiz.level ? 0

	listen: () =>
		if @config.httpPort
			wiz.log.warning "HTTP listening on [#{@config.httpHost}]:#{@config.httpPort}"
			@http.listen @config.httpPort, @config.httpHost
		if @config.httpsPort
			wiz.log.warning "HTTPS listening on [#{@config.httpsHost}]:#{@config.httpsPort}"
			@https.listen @config.httpsPort, @config.httpsHost

	start: () =>
		@master() if cluster.isMaster
		@worker() if cluster.isWorker

	redirect: (req, res, next, url = req.url, numeric = 303) =>
		return false unless @middleware.checkHostHeader req, res
		host = req.headers.host ? ''
		host = host.split(':')[0] if host.indexOf ':' != -1
		host += ":#{@config.httpsPortActual}" if @config.httpsPortActual != 443
		target = 'https://' + host + url
		res.redirect target, numeric
		return true

	catchall: (req, res) =>
		res.send 404
		return true

	# probably want to override this
	validateLogin: (req, res, cb) =>
		if not req.body.username is 'open' or not req.body.password is 'sesame'
			return cb 'login failed'
		cb null, true

	staticContent : [
		'css'
		'fonts'
		'img'
		'js'
	]

	cdnContent: [
		'download'
		'static'
	]

	staticPath: (url, disk, directory) =>
		return unless fs.existsSync disk
		#wiz.log.debug "adding static folder #{url} -> #{disk}"
		@https.use url, express.directory(disk) if directory
		@https.use url, express.static(disk)

# base branch class, extended by modules/resources/methods below
class wiz.framework.frontend.branch

	constructor: (@server, @parent, @path, @title = '', @view = 0, @level = 9000) ->
		@branches = {}
		# wiz.log.debug "creating #{@constructor.name} " + @getPath()
		wiz.assert(false, "invalid @parent: #{@parent}") if not @parent or typeof @parent != 'object'
		wiz.assert(false, "invalid @path: #{@path}") if not @path or typeof @path != 'string'

	getPath: () =>
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

	getPathSlashed: () =>
		path = @getPath()
		if path != '/'
			path = path + '/'
		return path

	getTitle : () =>
		return @title

	getLevel : () =>
		return @level

	getMask : () =>
		return @mask

	init: () =>
		# init all resources
		for branch of @branches
			# wiz.log.debug "initializing #{@constructor.name} " + branch
			if @branches[branch] instanceof Array
				b.init() for b in @branches[branch]
			else
				@branches[branch].init()

# for server modules
class wiz.framework.frontend.module extends wiz.framework.frontend.branch

	coffeeDir: '_coffee'
	coffeeExt: '.coffee'

	init: () =>
		tdir = rootpath + @getPathSlashed() + @coffeeDir
		if fs.existsSync(tdir)
			cpath = "/#{@coffeeDir}/:script#{@coffeeExt}"
			cof = new wiz.framework.frontend.method @parent, this, 'https', 'get', cpath, @parent.middleware.baseSession(), @server.powerMask.always, @server.powerLevel.stranger, @coffeeCompile
			cof.init()
		super()

	coffee: (file) =>
		return @getPathSlashed() + @coffeeDir + '/' + file + @coffeeExt

	coffeeCompile: (req, res) =>
		res.header 'Content-Type', 'application/x-javascript'
		fn = rootpath + @getPathSlashed() + @coffeeDir + '/' + req.params.script + @coffeeExt
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

		for staticDir in @parent.cdnContent
			path = @getPathSlashed() + staticDir + '/'
			@parent.staticPath path, rootpath + path, true

	initStaticDir: (path, dir) =>
		this[dir] = (file) => return path + file

# resources in a module
class wiz.framework.frontend.resource extends wiz.framework.frontend.branch

	method: (protocol, method, path, middleware, powerMask, powerLevel, handler) =>
		@branches[path] ?= []
		@branches[path].push(new wiz.framework.frontend.method(@parent.parent, this, protocol, method, path, middleware, powerMask, powerLevel, handler))
		return @branches[path]

# methods in a resource
class wiz.framework.frontend.method extends wiz.framework.frontend.branch

	constructor: (@server, @parent, @protocol, @method, @path, @middleware, @mask, @level, @handler) ->
		# wiz.log.debug @path
		# strip trailing / from request path
		if @path[@path.length - 1] == '/'
			@path = @path.slice(0, @path.length - 1)
		@init = () =>
			# wiz.log.debug "adding #{@protocol} #{@method} " + @getPath()
			wiz.assert(false, "invalid @server: #{@server}") if not @server
			@server[@protocol][@method](@getPath(), @middleware, (req, res) =>
				# wiz.log.debug "#{@server.userLevel(req)} and #{@getLevel()}"
				return res.send 404 unless @server.userLevel(req) >= @getLevel()
				req.wizMethodLevel = @getLevel()
				req.wizMethodMask = @getMask()
				req.wizMethodPublic = req.wizMethodMask < @server.powerMask.auth and req.wizMethodLevel < @server.powerLevel.friend
				@handler req, res
			)

# vim: foldmethod=marker wrap
