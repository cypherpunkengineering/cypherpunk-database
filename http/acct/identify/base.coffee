# copyright 2013 wiz technologies inc.

require '../../..'
require '../../resource/base'
require '../session'

wiz.package 'wiz.framework.http.acct.identify.base'

class wiz.framework.http.acct.identify.base extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.always

	userinfo: (req) => #{{{ returns a (safe to send) object containing user info from a user object
		return null unless req?.session?.user?

		out =
			auth: req?.session?.auth
			email: req?.session?.user?.email
			realname: req?.session?.user?.realname
			lastlogin: req?.session?.user?.lastlogin

		return out
	#}}}
	onIdentifySuccess: (req, res, user) => #{{{
		# TODO: call logout() here before creating new session
		# TODO: maybe better for security purposes if we dont allow a new login until existing session is logged out?

		# start a new session for the identified user
		wiz.framework.http.acct.session.start(req, res, user)

		# send session secret and user info
		out =
			secret: req.session.secret
			user: @userinfo(req)

		console.log out
		res.send 200, out
	#}}}

# vim: foldmethod=marker wrap
