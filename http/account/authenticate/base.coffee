# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../resource/base'
require '../session'

wiz.package 'wiz.framework.http.account.authenticate.base'

class wiz.framework.http.account.authenticate.base extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.always

	accountinfo: (req) => #{{{ returns a (safe to send) object containing account info from a account object
		return null unless req?.session?.account?

		out =
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
		req.server.root.accountDB.updateLastLoginTS req, res, (req2, res2, result) =>
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
		out =
			secret: req.session.secret
			account: @accountinfo(req)

		return out
	#}}}

# vim: foldmethod=marker wrap
