# copyright 2013 wiz technologies inc.

require '../../..'
require '../../resource/base'
require '../session'

wiz.package 'wiz.framework.http.acct.authenticate.base'

class wiz.framework.http.acct.authenticate.base extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.always

	acctinfo: (req) => #{{{ returns a (safe to send) object containing acct info from a acct object
		return null unless req?.session?.acct?

		out =
			auth: req?.session?.acct?.auth
			email: req?.session?.acct?.email
			fullname: req?.session?.acct?.fullname
			lastlogin: req?.session?.acct?.lastlogin

		return out
	#}}}
	onAuthenticateSuccess: (req, res, acct) => #{{{
		# TODO: call logout() here before creating new session
		# TODO: maybe better for security purposes if we dont allow a new login until existing session is logged out?

		# start a new session for the identified user
		wiz.framework.http.acct.session.start(req, res)

		# TODO: implement multiple factor auth (ie. half-logged-in)
		req.session.acct = acct
		req.session.auth = 1337 # XXX: temp hack

		# send session secret and acct info
		out =
			secret: req.session.secret
			acct: @acctinfo(req)

		res.send 200, out
	#}}}

# vim: foldmethod=marker wrap
