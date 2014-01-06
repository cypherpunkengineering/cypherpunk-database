# copyright 2013 wiz technologies inc.

require '../..'
require '../../crypto/hash'
require '../resource/base'
require '../db/mongo'
require './session'

require './db'
require './authenticate'
require './logout'

wiz.package 'wiz.framework.http.acct.module'

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

class wiz.framework.http.acct.module extends wiz.framework.http.resource.base
	#{{{ database config
	mongoConfig:
		hostname: 'localhost'
		database: 'wizacct'

	mongoServerOptions:
		auto_reconnect: true
		poolSize: 2

	mongoDbOptions:
		reaper: true
		safe: true
	#}}}
	load: () =>
		# create db driver
		@mongo = new wiz.framework.http.database.mongo.driver(@server, this, @mongoConfig, @mongoServerOptions, @mongoDbOptions)
		# connect to db
		@mongo.init()

		# create db classes with db driver instance
		@db =
			accounts: new wiz.framework.http.acct.db.accounts(@server, this, @mongo)
			otpkeys: new wiz.framework.http.acct.db.otpkeys(@server, this, @mongo)

		# load the account authentication sub-module
		@routeAdd new wiz.framework.http.acct.authenticate.module(@server, this, 'authenticate')
		@routeAdd new wiz.framework.http.acct.logout(@server, this, 'logout', 'POST')

# vim: foldmethod=marker wrap
