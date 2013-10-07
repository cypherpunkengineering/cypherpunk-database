# copyright 2013 wiz technologies inc.

require '../..'
require '../../crypto/hash'
require '../resource/base'
require '../db/mongo'
require './database'
require './session'

wiz.package 'wiz.framework.http.authenticate.base'

class wiz.framework.http.acct.authenticate.base extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.friend
	mask: wiz.framework.http.resource.power.mask.always
	middleware: wiz.framework.http.acct.session.secret

	onAuthenticateSuccess: (req, res, user) => #{{{

		# mark user as authenticated
		req.session.auth = true

		# send session secret and user info
		out =
			user: wiz.framework.http.acct.util.userinfo(req)

		out.s3 = req.session?.user?.s3 if req.body.piggyback == 's3credentials'

		if req.body.logout
			wiz.framework.http.acct.session.logout(req, res)
			out.loggedout = true

		return res.send 200, out

		# search database for given credentials
		#@user.usertable.findOneByUserPass req, res, req.session.wiz.portal, login, pass, (result) =>
	#}}}

# vim: foldmethod=marker wrap
