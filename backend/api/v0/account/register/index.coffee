# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'
require './_framework/thirdparty/stripe'

wiz.package 'cypherpunk.backend.api.v0.account.register'

class cypherpunk.backend.api.v0.account.register.signup extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	handler: (req, res) => #{{{
		# sanity checks on POST data
		return res.send 400, 'missing parameters' unless req.body?.email?
		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.email_valid(req.body.email)

		# TODO XXX FIXME: validate and save referral code if any
		referralData =
			referralID: req.body?.referralCode # optional

		# pass to signup method for processing
		@server.root.api.user.database.signupTrial req, res, null, (req2, res2, user) =>

			# create authenticated session for new account
			out = @parent.parent.doUserLogin(req, res, user)

			# send account status with "created" response
			return res.send 202, out
	#}}}

class cypherpunk.backend.api.v0.account.register.teaser extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	handler: (req, res) => #{{{
		# sanity checks on POST data
		return res.send 400, 'missing parameters' unless req.body?.email?
		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.email_valid(req.body.email)

		# pass to signup method for processing
		@server.root.api.user.database.signupTeaser req, res, null, (req2, res2, user) =>

			# create authenticated session for new account
			out = @parent.parent.doUserLogin(req, res, user)

			# send account status with "created" response
			return res.send 202, out
	#}}}

class cypherpunk.backend.api.v0.account.register.teaserShare extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.friend
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.base
	handler: (req, res) => #{{{
		# sanity checks on POST data
		return res.send 400, 'missing parameters' unless req.body?.email?
		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.email_valid(req.body.email)

		# save referring friend id + name
		referralData =
			referralID: req.session.account.id # this user's account is sharing
			referralName: req.body?.name # optional

		# pass to signup method for processing
		@server.root.api.user.database.signupTeaser req, res, referralData, (req2, res2, user) =>

			# create authenticated session for new account
			out = @parent.parent.doUserLogin(req, res, user)

			# send account status with "created" response
			return res.send 202, out
	#}}}

class cypherpunk.backend.api.v0.account.register.resource extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	load: () =>
		# inherit
		super()

		# public account creation api
		@routeAdd new cypherpunk.backend.api.v0.account.register.signup(@server, this, 'signup', 'POST')
		@routeAdd new cypherpunk.backend.api.v0.account.register.teaser(@server, this, 'teaser', 'POST')
		@routeAdd new cypherpunk.backend.api.v0.account.register.teaserShare(@server, this, 'teaserShare', 'POST')

# vim: foldmethod=marker wrap
