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
	load: () =>
		# create db driver
		#@mongo = null # new wiz.framework.http.database.mongo.driver(@server, this, @mongoConfig, @mongoServerOptions, @mongoDbOptions)

		# create db classes with db driver instance
		#@db = null
		#customers: new wiz.framework.http.account.db.customers(@server, this, @mongo)
		#staff: new wiz.framework.http.account.db.staff(@server, this, @mongo)
		#otpkeys: new wiz.framework.http.account.db.otpkeys(@server, this, @mongo)

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
