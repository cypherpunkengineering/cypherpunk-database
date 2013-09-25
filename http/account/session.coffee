# copyright 2013 wiz technologies inc.

require '../..'
require '../resource/middleware'

crypto = require 'crypto'
BigInteger = require '../../crypto/jsbn'

wiz.package 'wiz.framework.http.account.session'
wiz.sessions = {}

class wiz.framework.http.account.session
	@cookieName: 'wiz.session' # must be static for middleware
	expires: 60 # minutes from now
	path: '/'

	@load: (req, res) => # middleware to load session if cookie present {{{
		try
			cookie = req.cookies?[wiz.framework.http.account.session.cookieName]
			id = decodeURIComponent(cookie)
			key = wiz.framework.crypto.hash.salthash(id, 'base64')
			req.session = wiz.sessions[key]
		catch e
			#wiz.log.debug "no session: #{e}"
			req.session = undefined

		if req.session
			req.session.last = new Date() # update session time
			res.setCookie req.session.cookie() # update cookie expiration time

		# call next middleware
		req.next()
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
			wiz.sessions[req.session.key] = req.session
	#}}}
	@start: (req, res, user) => #{{{ start new session
		req.session = new wiz.framework.http.account.session()
		req.session.user = user
		res.setCookie req.session.cookie()
	#}}}
	@logout: (req, res) => #{{{ destroy session
		if req?.session?.key
			wiz.sessions[req.session.key] = undefined
			req.session = undefined
	#}}}
	constructor: () -> #{{{ create new session
		# session timestamps
		@started = @last = new Date()

		# default session values
		@auth = false
		@user = null

		# generate secure session id and secret
		@id = crypto.randomBytes(64).toString('base64')
		s = new BigInteger(crypto.randomBytes(64))
		@secret = wiz.framework.crypto.convert.biToBase32(s)

		# generate session key from salthash(id)
		@key = wiz.framework.crypto.hash.salthash(@id, 'base64')
	#}}}
	cookie: (req, res) => #{{{ generate a cookie for the session

		# cookie object
		cookie =
			name: wiz.framework.http.account.session.cookieName
			val: @id
			expires: new Date(@last.getTime() + (@expires * 60 * 1000))

		return cookie
	#}}}

# vim: foldmethod=marker wrap
