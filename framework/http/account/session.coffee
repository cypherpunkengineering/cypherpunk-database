# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../resource/middleware'

crypto = require 'crypto'
redis = require 'redis'
BigInteger = require '../../crypto/jsbn'

wiz.package 'wiz.framework.http.account.session'

wiz.sessions = redis.createClient()

class wiz.framework.http.account.session
	@cookieName: 'cypherpunk.session' # must be static for middleware
	@lifetime = 60 * 24 * 365 # minutes
	@debug: false

	@getSessionKeyFromSecret: (req, res) => # middleware to load session from secret if provided {{{
		return req.next() if req.sessionKey?
		try
			secret = req.params?.secret
			secret ?= req.body?.secret
			return req.next() unless secret
			wiz.log.debug "got secret #{secret}" if @debug

			wiz.sessions.get secret, (err, datum) =>
				if err or not datum
					err ?= "secret not in database"
					wiz.log.err "error loading secret: #{err}"
					req.sessionKey = undefined
					return req.next() # call next middleware

				wiz.log.debug "got session key from secret #{datum}"
				req.sessionKey = datum
				return req.next() # call next middleware

		catch e
			wiz.log.debug "unable to load secret: #{e}"
			req.sessionKey = undefined
			req.next() # call next middleware
	#}}}
	@getSessionKeyFromCookie: (req, res) => # middleware to load session from cookie if provided {{{
		return req.next() if req.sessionKey?
		try
			# get session cookie
			cookie = req.cookies?[@cookieName]
			return req.next() unless cookie

			# get session id from session cookie
			id = decodeURIComponent(cookie)
			wiz.log.debug "got session id #{id}" if @debug

			# get session key by hashing session id
			key = wiz.framework.crypto.hash.salthash(id, 'base64')
			wiz.log.debug "got session key #{key}" if @debug

			req.sessionKey = key
			return req.next() # call next middleware

		catch e
			wiz.log.debug "unable to get session key: #{e}"
			req.sessionKey = undefined
			req.next() # call next middleware
	#}}}
	@loadSessionFromKey: (req, res) => #{{{ load session by session key
		try
			return req.next() unless req.sessionKey?

			# get session from session store by session key
			wiz.sessions.get req.sessionKey, (err, datum) =>

				if err or not datum
					wiz.log.err "error loading session: #{err}" if err
					req.session = undefined
					return req.next() # call next middleware

				req.session = JSON.parse(datum)
				req.session.last = new Date() # update session time
				@cookie(req, res)
				console.log req.session if @debug
				return req.next() # call next middleware

		catch e
			wiz.log.debug "unable to load session: #{e}"
			req.session = undefined
			req.next() # call next middleware
	#}}}
	@refreshSessionFromDB: (req, res) => #{{{ refresh account object from db
		return req.next() unless req.session?.account?.id?
		req.server.root.accountDB.findOneByID req, res, req.session.account.id, (req2, res2, account) =>
			return req.next() unless account?
			req.session.account = account
			req.next()
	#}}}
	@checkSecret: (req, res) => # {{{ check if CSRF secret token matches
		if req.session?.secret and req.body?.secret
			serverSecret = wiz.framework.crypto.hash.salthash(req.session.secret)
			userSecret = wiz.framework.crypto.hash.salthash(req.body.secret)
			return req.next() if serverSecret == userSecret

		res.send 400, "missing or invalid secret token"
	#}}}
	@usernav: (req, res) => #{{{

		req.nav ?= {}
		root = req.route.server.rootnav or req.route.server.root

		for route of root.routeTable when module = root.routeTable[route]
			resources = []
			if module.isVisible(req)
				#console.log module.title

				for r of module.routeTable when resource = module.routeTable[r]
					subresources = []
					if resource.isVisible(req)
						#console.log resource.title
						for sr of resource.routeTable when subresource = resource.routeTable[sr]
							subresources.push
								title: subresource.title
								path: subresource.getFullPath()

						resources.push
							title: resource.title
							path: resource.getFullPath()
							subresources: subresources
							subresourceCount: subresources.length

				req.nav[module.path] =
					title: module.title
					path: module.getFullPath()
					resources: resources
					resourceCount: resources.length

		req.next()
	#}}}

	# array must come after middleware methods after it is defined
	@base: wiz.framework.http.resource.middleware.base.concat [ #{{{ base list of middleware required for session use
		@getSessionKeyFromSecret
		@getSessionKeyFromCookie
		@loadSessionFromKey
		@refreshSessionFromDB
		wiz.framework.http.resource.middleware.checkAccess
		@usernav
	] #}}}
	@norefresh: wiz.framework.http.resource.middleware.base.concat [ #{{{ special norefresh list
		@getSessionKeyFromSecret
		@getSessionKeyFromCookie
		@loadSessionFromKey
		wiz.framework.http.resource.middleware.checkAccess
		@usernav
	] #}}}
	@csrf: @base.concat [ #{{{ above list and check CSRF secret token
		@checkSecret
	] #}}}
	@refresh: @base.concat [ #{{{ above list and check CSRF secret token
	] #}}}

	@save: (req) => # save session to db after sending response {{{
		if req?.session?.key
			#wiz.log.debug "storing session key #{req.session.key} data #{JSON.stringify(req.session)}"
			#for x of req.session
				#console.log x
				#console.log req.session[x]
			wiz.sessions.set(req.session.key, JSON.stringify(req.session))
			wiz.sessions.set(req.session.secret, req.session.key)
			wiz.sessions.expire(req.session.key, @lifetime * 60)
			wiz.sessions.expire(req.session.secret, @lifetime * 60)
	#}}}
	@start: (req, res) => #{{{ start new session
		# create session object
		req.session = {}
		# session timestamps
		req.session.started = req.session.last = new Date()

		# default session values
		req.session.auth = false
		req.session.account = null
		req.session.expires = @lifetime
		req.session.realm = 'cypherpunk'

		# generate secure session id and secret
		req.session.id = crypto.randomBytes(64).toString('base64')
		s = new BigInteger(crypto.randomBytes(64))
		req.session.secret = wiz.framework.crypto.convert.biToBase32(s)

		# generate session key from salthash(id)
		req.session.key = wiz.framework.crypto.hash.salthash(req.session.id, 'base64')

		# generate session cookie
		@cookie(req, res)
	#}}}
	@logout: (req, res) => #{{{ destroy session
		wiz.sessions.del(req.session.key) if req?.session?.key?
		wiz.sessions.del(req.session.secret) if req?.session?.secret?
		req.session = undefined
	#}}}
	@cookie: (req, res) => #{{{ set-cookie for the session

		if not req?.session?.id? or not req?.session?.last?
			return wiz.log.crit 'invalid session, unable to set-cookie'

		c = # c is for cookie
			name: @cookieName
			val: req.session.id
			expires: new Date(req.session.last.getTime() + (req.session.expires * 60 * 1000))

		res.setCookie(c)
		#wiz.log.debug "set session cookie #{JSON.stringify(req.cookie)}"
	#}}}

# vim: foldmethod=marker wrap
