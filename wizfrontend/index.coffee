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

# wiz-framework
require '..'

# wizfrontend package
wizpackage 'wizfrontend'
require './database'
require './middleware'

# node frameworks
coffee = require 'coffee-script'
connect = require 'connect'
express = require 'express'
jade = require 'jade'
fs = require 'fs'

# session storage
RedisStore = require('connect-redis')(connect)

# server config object
class wizfrontend.serverConfig
	sessionSecret : 'ChangeMeBecauseThisDefaultIsNotSecret'
	requestLimit : '2mb'

	httpHost: '::'
	httpPort: 10080

	httpsHost: '::'
	httpsPort: 10443
	httpsKey: rootpath + '/ssl/wizkey.pem'
	httpsCert: rootpath + '/ssl/wizcert.pem'

# main server class
class wizfrontend.server

	config : new wizfrontend.serverConfig()
	constructor: () ->
		wizlog.warning @constructor.name, 'Server starting...'

		# create middleware structure
		@sessionRedisStore = new RedisStore()
		@middleware = new wizfrontend.middleware(@)

		# create http server for redirecting non-ssl requests to https: url
		@http = express.createServer()

		# create https server with local key/cert
		@https = express.createServer
			key: fs.readFileSync @config.httpsKey
			cert: fs.readFileSync @config.httpsCert

		# add module list, core module, and home resource
		@modules = {}
		@core = @module '/', 'core'
		@home = @core.resource '/', 'home'

		@home.method 'https', 'get', '/js/:script.js', @middleware.baseSession(), (req, res) =>
			res.header 'Content-Type', 'application/x-javascript'
			fs.readFile "#{rootpath}/js/#{req.params.script}.coffee", 'utf8', (err, data) ->
				if err
					res.send 404
					return false
				js = coffee.compile data,
					bare: true
				res.send js

		# add core methods
		@home.method 'https', 'get', '/', @middleware.baseSession(), @handleRoot
		@home.method 'https', 'get', '/home', @middleware.baseSessionAuth(), @handleHome
		@home.method 'https', 'post', '/login', @middleware.baseSession(), @handleLogin
		@home.method 'https', 'get', '/logout', @middleware.baseSession(), @handleLogout

	module: (path, title) =>
		@modules[path] = new wizfrontend.module this, path, title
		return @modules[path]

	init: () =>
		# first, add static directories
		for module of @modules
			@modules[module].initStatic()

		# data filled in from child modules
		@viewsFolders = []
		@nav = {}

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

			# calculate nav tree for non-root modules
			if @modules[module].getPath() != '/'
				@nav[module] =
					title: @modules[module].getTitle()
					path: @modules[module].getPath()
					resources: {}
				for resource of @modules[module].branches
					@nav[module].resources[resource] =
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
		@redirect req, res, null, '/'

	handleRoot: (req, res) =>
		res.send 'this is the root'

	handleHome: (req, res) =>
		res.send 'home'

	handleLogin : (req, res) =>
		# check if valid login
		if @validateLogin req, res
			# log them in and redirect home
			req.session.wizfrontendAuth = true
			wizlog.debug @constructor.name, "login-ok redirect"
			@redirect req, res, null, '/'
		else
			# login failed
			wizlog.debug @constructor.name, "login-failed redirect"
			@redirect req, res, null, '/?fail=1'

	handleLogout: (req, res) =>
		# log them out and redirect home
		req.session.wizfrontendAuth = false
		wizlog.debug @constructor.name, "logout-ok redirect"
		@redirect req, res, null, '/?out=1'

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

	redirect: (req, res, next, url = req.url, code = 302) =>
		unless @middleware.checkHostHeader req, res
			return false
		res.redirect "https://#{req.headers["host"]}#{url}", code
		return true

	catchall: (req, res) =>
		ip = @middleware.getIP req
		if req.url is '/'
			wizlog.err @constructor.name, "recursive redirect: #{ip}"
			res.send 'recursive redirect'
			return false
		wizlog.debug @constructor.name, "catchall redirect: #{ip}"
		@redirect req, res, null, '/'
		return true

	# probably want to override this
	validateLogin: (req, res) =>
		return req.body.username is 'open' and req.body.password is 'sesame'

	staticContent : [
		'css'
		'img'
		'js'
	]

	staticPath: (url, disk) =>
		wizlog.debug @constructor.name, "adding static folder #{url} -> #{disk}"
		@https.use url, express.static(disk)

# base branch class, extended by modules/resources/methods below
class wizfrontend.branch

	constructor: (@parent, @path, @title) ->
		# wizlog.debug @constructor.name, "creating #{@constructor.name} " + @getPath()
		@branches = {}

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

	getTitle : () =>
		return @title

	init: () =>
		# init all resources
		for branch of @branches
			# wizlog.debug @constructor.name, "initializing #{@constructor.name} " + branch
			@branches[branch].init()

# for server modules
class wizfrontend.module extends wizfrontend.branch

	resource: (path, title) =>
		@branches[path] = new wizfrontend.resource this, path, title
		return @branches[path]

	initStatic: () =>
		# module-level static folders
		for staticDir in @parent.staticContent
			path = @getPath()
			if path != '/'
				path = path + '/'
			path = path + '_' + staticDir + '/'
			@parent.staticPath path, rootpath + path
			@initStaticDir(path, staticDir)

	initStaticDir: (path, dir) =>
		this[dir] = (file) => return path + file

# resources in a module
class wizfrontend.resource extends wizfrontend.branch

	method: (protocol, method, path, middleware, handler) =>
		@branches[path] = new wizfrontend.method this, protocol, method, path, middleware, handler
		return @branches[path]

# methods in a resource
class wizfrontend.method extends wizfrontend.branch

	constructor: (@parent, @protocol, @method, @path, @middleware, @handler) ->
		# wizlog.debug @constructor.name, @path
		# strip trailing / from request path
		if @path[@path.length - 1] == '/'
			@path = @path.slice(0, @path.length - 1)
		@init = () =>
			wizlog.debug @constructor.name, "adding #{@protocol} #{@method} " + @getPath()
			@parent.parent.parent[@protocol][@method](@getPath(), @middleware, @handler)

# vim: foldmethod=marker wrap
