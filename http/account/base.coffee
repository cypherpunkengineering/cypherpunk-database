# copyright 2013 wiz technologies inc.

require '../..'
require '../../crypto/otp'
require '../../crypto/hash'
require '../resource/base'
require './session'

wiz.package 'wiz.framework.http.account'

wiz.keys = {} # TODO: connect to database

class wiz.framework.http.account.module extends wiz.framework.http.resource.base
	init: () => #{{{
		@routeAdd new wiz.framework.http.account.identify(@server, this, 'identify', 'POST')
		@routeAdd new wiz.framework.http.account.authenticate(@server, this, 'authenticate', 'POST')
	#}}}

class wiz.framework.http.account.util
	@userinfo: (req) => #{{{ returns a (safe to send) object containing user info from a user object
		return null unless req?.session?.user?

		out =
			auth: req?.session?.auth
			email: req?.session?.user?.email
			realname: req?.session?.user?.realname
			lastlogin: req?.session?.user?.lastlogin

		return out
	#}}}

class wiz.framework.http.account.identify extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.always
	handler: (req, res) => #{{{
		return res.send 400, 'missing key' unless req.body?.key?
		return res.send 400, 'invalid key' unless wiz.framework.util.strval.pengikey_valid(req.body.key)
		return res.send 400, 'unknown key' unless user = wiz.keys[req.body.key]

		return res.send 400, 'missing otp' unless req.body?.otp?
		return res.send 400, 'invalid otp' unless wiz.framework.util.strval.hotp_valid(req.body.otp)

		validationHOTP = wiz.framework.crypto.otp.validateHOTP(user.secret, user.counter, req.body.otp, 1000)

		return res.send 400, 'otp validation failed' unless validationHOTP.result is true

		# FIXME: maybe call logout() here?

		# start a new session for the identified user
		wiz.framework.http.account.session.start(req, res, user)

		# send session secret and user info
		out =
			secret: req.session.secret
			user: wiz.framework.http.account.util.userinfo(req)

		res.send 200, out
	#}}}

class wiz.framework.http.account.authenticate extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.friend
	mask: wiz.framework.http.resource.power.mask.always
	middleware: wiz.framework.http.account.session.secret

	handler: (req, res, cb) => #{{{
		if not (req.body?.password? and req.session?.user?.password? and req.body?.password == req.session?.user?.password)
			return res.send 400, 'password authentication failed'

		# mark user as authenticated
		req.session.auth = true

		# send session secret and user info
		out =
			user: wiz.framework.http.account.util.userinfo(req)

		out.s3 = req.session?.user?.s3 if req.body.piggyback == 's3credentials'

		if req.body.logout
			wiz.framework.http.account.session.logout(req, res)
			out.loggedout = true

		return res.send 200, out

		# search database for given credentials
		#@user.usertable.findOneByUserPass req, res, req.session.wiz.portal, login, pass, (result) =>
	#}}}

# vim: foldmethod=marker wrap
