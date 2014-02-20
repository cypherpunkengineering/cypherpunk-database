# copyright 2013 wiz technologies inc.

require '../..'
require '../resource/middleware'

crypto = require 'crypto'
redis = require 'redis'
BigInteger = require '../../crypto/jsbn'

wiz.package 'wiz.framework.http.acct.session'

wiz.sessions = redis.createClient()

class wiz.framework.http.acct.session
	@cookieName: 'wiz.session' # must be static for middleware

	@load: (req, res) => # middleware to load session if cookie present {{{
		try
			# get session cookie
			cookie = req.cookies?[wiz.framework.http.acct.session.cookieName]
			return req.next() if not cookie

			# get session id from session cookie
			id = decodeURIComponent(cookie)
			#wiz.log.debug "got session id #{id}"

			# get session key by hashing session id
			key = wiz.framework.crypto.hash.salthash(id, 'base64')
			#wiz.log.debug "got session key #{key}"

			# get session from session store by session key
			wiz.sessions.get key, (err, datum) =>

				if err or not datum
					wiz.log.err "error loading session: #{err}" if err
					req.session = undefined
					return req.next() # call next middleware

				req.session = JSON.parse(datum)
				req.session.last = new Date() # update session time
				wiz.framework.http.acct.session.cookie(req, res)
				#console.log req.session
				return req.next() # call next middleware

		catch e
			wiz.log.debug "unable to load session: #{e}"
			req.session = undefined
			req.next() # call next middleware
	#}}}
	@checkSecret: (req, res) => # {{{ check if CSRF secret token matches
		if req.session?.secret and req.body?.secret
			serverSecret = wiz.framework.crypto.hash.salthash(req.session.secret)
			userSecret = wiz.framework.crypto.hash.salthash(req.body.secret)
			return req.next() if serverSecret == userSecret

		res.send 400, "missing or invalid secret token"
	#}}}
	# array must come after middleware methods after it is defined
	@base: wiz.framework.http.resource.middleware.base.concat [ #{{{ base list of middleware required for session use
		@load
		wiz.framework.http.resource.middleware.checkAccess
	] #}}}
	@secret: @base.concat [ #{{{ above list and check CSRF secret token
		@checkSecret
	] #}}}

	@save: (req) => # save session to db after sending response {{{
		if req?.session?.key
			#wiz.log.debug "storing session key #{req.session.key} data #{JSON.stringify(req.session)}"
			wiz.sessions.set(req.session.key, JSON.stringify(req.session))
	#}}}
	@start: (req, res) => #{{{ start new session
		# create session object
		req.session = {}
		# session timestamps
		req.session.started = req.session.last = new Date()

		# default session values
		req.session.auth = false
		req.session.acct = null
		req.session.expires = 60 # minutes
		req.session.realm = 'wiz'

		# generate secure session id and secret
		req.session.id = crypto.randomBytes(64).toString('base64')
		s = new BigInteger(crypto.randomBytes(64))
		req.session.secret = wiz.framework.crypto.convert.biToBase32(s)

		# generate session key from salthash(id)
		req.session.key = wiz.framework.crypto.hash.salthash(req.session.id, 'base64')

		# generate session cookie
		wiz.framework.http.acct.session.cookie(req, res)
	#}}}
	@logout: (req, res) => #{{{ destroy session
		if req?.session?.key
			wiz.sessions.del(req.session.key)
			req.session = undefined
	#}}}
	@cookie: (req, res) => #{{{ set-cookie for the session

		if not req?.session?.id? or not req?.session?.last?
			return wiz.log.crit 'invalid session, unable to set-cookie'

		c = # c is for cookie
			name: wiz.framework.http.acct.session.cookieName
			val: req.session.id
			expires: new Date(req.session.last.getTime() + (req.session.expires * 60 * 1000))

		res.setCookie(c)
		#wiz.log.debug "set session cookie #{JSON.stringify(req.cookie)}"
	#}}}

# vim: foldmethod=marker wrap
