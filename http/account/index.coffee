# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../../crypto/hash'
require '../resource/base'
require '../db/mongo'
require './session'

require './db'
require './identify'
require './authenticate'
#require './otpkeys'
require './logout'

wiz.package 'wiz.framework.http.account.module'

# user login is a two-step process:
#{{{ 1. identification
#
#	if request validates, HTTP 200 response will contain session id in Set-Cookie header, and:
#	{
#		"secret" : "session secret string aka CSRF token"
#		"auth" : ("otp" or "pw")
#		"user" : {info object for identified user}
#	}
#
#	else, you get a HTTP 400 response with reason why identification failed.
#
#}}}
#{{{ 2. authentication:
#
#	if using yubikey authentication, the request must contain:
#
#		a) cookie header with session id (from Set-Cookie header in identification response)
#		b) JSON body with:
#			1) session secret (aka CSRF token)
#			2) user password (together with previous yubikey OTP achieves two factor auth)
#
#	else if otp_required is TRUE (ie. TOTP smartphone app), the request body must contain:
#
#		a) cookie header with session id (from Set-Cookie header in identification response)
#		b) JSON body with:
#			1) session secret
#			2) smartphone TOTP code
#
#	else if not using OTP (one factor), the request body must contain:
#
#		a) cookie header with session id (from Set-Cookie header in identification response)
#		b) JSON body with:
#			1) session secret
#			2) user password
#
#}}}

class wiz.framework.http.account.module extends wiz.framework.http.resource.base
	database: null # instantiate db from child class

	accountinfo: (req) => #{{{ returns a (safe to send) object containing account info from a account object
		return null unless req?.session?.id?
		return null unless req?.session?.account?

		out =
			secret: req.session.secret
			account:
				id: req?.session?.account?.id
				auth: req?.session?.account?.auth
				email: req?.session?.account?.data?.email
				confirmed: req?.session?.data?.confirmed
				fullname: req?.session?.account?.data?.fullname
				#lastlogin: req?.session?.account?.lastlogin
				powerLevel: req?.session?.powerLevel

		return out
	#}}}
	onAuthenticateSuccess: (req, res, account) => #{{{
		out = @doUserLogin(req, res, account)
		res.send 200, out
		@database.updateLastLoginTS req, res, (req2, res2, result) =>
	#}}}
	doUserLogin: (req, res, account) => #{{{
		# TODO: call logout() here before creating new session
		# TODO: maybe better for security purposes if we dont allow a new login until existing session is logged out?

		# start a new session for the identified user
		wiz.framework.http.account.session.start(req, res)

		# TODO: implement multiple factor auth (ie. half-logged-in)
		req.session.account = account

		req.session.powerLevel = 0
		if @server.powerLevel and account.type and @server.powerLevel[account.type]
			req.session.powerLevel = @server.powerLevel[account.type]
		else
			wiz.log.crit "unable to set user's power level!"

		req.session.auth = 1337 # XXX: temp hack

		# send session secret and account info
		out = @accountinfo(req)
		return out
	#}}}

	load: () =>
		# create db driver
		#@mongo = null # new wiz.framework.http.database.mongo.driver(@server, this, @mongoConfig, @mongoServerOptions, @mongoDbOptions)

		# logout and destroy session
		@routeAdd new wiz.framework.http.account.logout(@server, this, 'logout', 'POST')

		# load the account identify sub-module
		@identify = @routeAdd new wiz.framework.http.account.identify.module(@server, this, 'identify')

		# load the account authentication sub-module
		@authenticate = @routeAdd new wiz.framework.http.account.authenticate.module(@server, this, 'authenticate')

		# load the account otpkeys sub-module
		# @routeAdd new wiz.framework.http.account.otpkeys.module(@server, this, 'otpkeys')

	init: () =>
		# connect to db
		#@mongo.init()

# vim: foldmethod=marker wrap
