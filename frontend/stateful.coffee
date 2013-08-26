# copyright 2013 wiz technologies inc.

require '..'
require './server'
require './database'
require './middleware'
require '../util/bitmask'
require './power'

wiz.package 'wiz.framework.frontend.stateful'

# node frameworks
connect = require 'connect'
express = require 'express'
fs = require 'fs'

RedisStore = require('connect-redis')(connect)

class wiz.framework.frontend.stateful.config extends wiz.framework.frontend.config #{{{
	sessionSecret : 'ChangeMeBecauseThisDefaultIsNotSecret'
	requestLimit : '2mb'

	favicon: ''

	express:
		key: ''
		cert: ''
		ca: ''
#}}}

class wiz.framework.frontend.stateful.server extends wiz.framework.frontend.server

	constructor: () -> #{{{
		super()
		@config = new wiz.framework.frontend.stateful.config()
		@powerMask = new wiz.framework.frontend.powerMask()
		@powerLevel = new wiz.framework.frontend.powerLevel()
	#}}}

	preModuleCreate: () => #{{{
		# create middleware structure
		@sessionStore = new @createSessionStore()
		@middleware = new wiz.framework.frontend.middleware(@)

		# pass express configuration if present
		if @config.express
			@http = express.createServer @config.express
		else
			@http = express.createServer()

		@http.use b for b in @middleware.base()
		@http.use express.favicon @config.favicon

		# create empty module list
		@modules = {}

		# special core module and home resource
		@core = @module(new wiz.framework.frontend.module(@, @, '/', 'Home', @powerMask.public, @powerLevel.stranger))
		@root = @core.resource(new wiz.framework.frontend.resource(@, @core, '/', '', @powerMask.always, @powerLevel.stranger))

		# login and logout modules
		@login = @module(new wiz.framework.frontend.module(@, @, '/login', null, @powerMask.public, @powerLevel.stranger))
		@logout = @module(new wiz.framework.frontend.module(@, @, '/logout', null, @powerMask.auth, @powerLevel.stranger))

		# public methods
		@root.method 'get', '/', @middleware.baseSession(), @powerMask.always, @powerLevel.stranger, @handleRoot
		@root.method 'get', '/login', @middleware.baseSession(), @powerMask.always, @powerLevel.stranger, @getLogin
		@root.method 'post', '/login', @middleware.baseSession(), @powerMask.always, @powerLevel.stranger, @postLogin
		@root.method 'get', '/logout', @middleware.baseSession(), @powerMask.always, @powerLevel.stranger, @getLogout
		@root.method 'post', '/logout', @middleware.baseSession(), @powerMask.always, @powerLevel.stranger, @postLogout

		# for logged in users
		@root.method 'get', '/home', @middleware.baseSessionAuth(), @powerMask.auth, @powerLevel.friend, @handleHome
	#}}}

	createSessionStore: () => #{{{
		return new RedisStore()
	#}}}

	nav: (req) => #{{{
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
	#}}}

	navView: (result, ul, nv) => #{{{
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
	#}}}

	postModuleInit: () => #{{{

		@http.set 'views', @viewsFolders
		@http.set 'view engine', 'jade'
		@http.set 'view options',
			layout: false
			pretty : true

		@http.use (err, req, res, next) =>
			# pass errors to error handler
			return @error err, req, res

		# finally, add catchall at the end
		@http.all '*', @middleware.baseSession(), @catchall

		# Jade configuration
		@expressMultiViews express # enable multiple views directories

		super()
	#}}}

	listen: () => #{{{
		if @config.httpPort
			wiz.log.warn "HTTP listening on [#{@config.httpHost}]:#{@config.httpPort}"
			@http.listen @config.httpPort, @config.httpHost
	#}}}

	expressMultiViews : (express) => #{{{

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
	#}}}

	handleRoot: (req, res) => #{{{
		res.send 'this is the root'
	#}}}
	handleHome: (req, res) => #{{{
		res.send 'home'
	#}}}

	getLogin: (req, res) => #{{{
		res.send 'login page'
		# implement a login page in child class
	#}}}
	postLogin : (req, res) => #{{{
		@validateLogin req, res, (err, ok) =>
			if err
				wiz.log.err "login failed: #{err}"
				res.send err, 400
				return

			# login okay, do login and and redirect home
			@doLogin req if ok
			res.send 200
	#}}}

	getLogout: (req, res) => #{{{
		# log them out and redirect home
		wiz.log.debug "Logging out, sending redirect"
		@doLogout req
		@redirectToRoot req, res
	#}}}
	postLogout: (req, res) => #{{{
		# log them out and redirect home
		wiz.log.debug "Logging out, sending 200 OK"
		@doLogout req
		res.send 200
	#}}}

	sessionCreate: (req, res, next) => #{{{ initialize all session variables
		req.session.wiz ?= {}
		return next() if next
		return true
	#}}}
	sessionDestroy: (req) => #{{{
		req.session.wiz = {}
	#}}}
	sessionInit: (req, res, next) => #{{{
		req.session.wiz.auth ?= false
		req.session.wiz.mask ?= wiz.framework.util.bitmask.set(0, @powerMask.public)
		req.session.wiz.level ?= @powerLevel.stranger
		return next() if next
		return true
	#}}}

	doLogin: (req) => #{{{
		req.session.wiz.auth = true
		req.session.wiz.mask = 0
		req.session.wiz.mask = wiz.framework.util.bitmask.set req.session.wiz.mask, @powerMask.always
		req.session.wiz.mask = wiz.framework.util.bitmask.set req.session.wiz.mask, @powerMask.auth
		if req.session.wiz.level < @powerLevel.friend
			req.session.wiz.level = @powerLevel.friend
	#}}}
	doLogout: (req) => #{{{
		@sessionDestroy req
		@sessionCreate req
	#}}}

	userMask: (req) => #{{{
		return 0 if not req.session or not req.session.wiz
		return req.session.wiz.mask ? 0
	#}}}
	userLevel: (req) => #{{{
		return 0 if not req.session or not req.session.wiz
		return req.session.wiz.level ? 0
	#}}}

	staticContent : [ #{{{ static content folders
		'css'
		'fonts'
		'img'
		'js'
	] #}}}
	cdnContent: [ #{{{ static download content folders
		'download'
		'static'
	] #}}}
	staticPath: (url, disk, directory) => #{{{ adds a route for a given static path
		return unless fs.existsSync disk
		#wiz.log.debug "adding static folder #{url} -> #{disk}"
		@http.use url, express.directory(disk, { icons: true } ) if directory
		@http.use url, express.static(disk)
	#}}}

# vim: foldmethod=marker wrap
