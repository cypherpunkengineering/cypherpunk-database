# copyright 2013 wiz technologies inc.

require '../..'
require '../../crypto/otp'
require '../../crypto/hash'
require '../resource/base'
require './session'

wiz.package 'wiz.framework.http.account'

class wiz.framework.http.account.module extends wiz.framework.http.resource.base
	init: () => #{{{
		@routeAdd new wiz.framework.http.account.identify(@server, this, 'identify', 'POST')
		@routeAdd new wiz.framework.http.account.authenticate(@server, this, 'authenticate', 'POST')
	#}}}

class wiz.framework.http.account.util
	@pwhash: (plaintext) => #{{{
		salt = 'angelheaded hipsters burning for the ancient heavenly connection to the starry dynamo in the machinery of night'
		nugget = (s + plaintext for s in salt.split(' '))
		hash = wiz.framework.crypto.hash.digest nugget
		return hash
	#}}}

class wiz.framework.http.account.identify extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.public
	handler: (req, res) => #{{{

		return res.send 400, 'missing key' unless req.body?.key?
		return res.send 400, 'invalid key' unless wiz.framework.util.strval.pengikey_valid(req.body.key)
		return res.send 400, 'unknown key' unless user = wiz.keys[req.body.key]

		return res.send 400, 'missing otp' unless req.body?.otp?
		return res.send 400, 'invalid otp' unless wiz.framework.util.strval.hotp_valid(req.body.otp)

		validationHOTP = wiz.framework.crypto.otp.validateHOTP(user.secret, user.counter, req.body.otp, 1000)

		return res.send 400, 'otp validation failed' unless validationHOTP.result is true

		session = new wiz.framework.http.account.session(req, res)
		session.user = user
		session.auth = true

		out =
			email: user.email
			realname: user.realname
			lastlogin: user.lastlogin

		res.send 200, out
	#}}}

class wiz.framework.http.account.authenticate extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.friend
	mask: wiz.framework.http.resource.power.mask.auth
	middleware: wiz.framework.http.account.session.base

	handler: (req, res, cb) => #{{{
		return res.send 400, 'invalid session' if not req.session?.auth or not req.session?.user?

		if not (req.body?.password? and req.session?.user?.password? and req.body?.password == req.session?.user?.password)
			return res.send 400, 'password authentication failed'

		out =
			auth: 1
			user:
				realname: req.session?.user?.realname

		out.s3 = req.session?.user?.s3 if req.body.piggyback == 's3credentials'

		if req.body.logout
			out.logout = true

		return res.send 200, out

		# search database for given credentials
		#@user.usertable.findOneByUserPass req, res, req.session.wiz.portal, login, pass, (result) =>
	#}}}

# vim: foldmethod=marker wrap
