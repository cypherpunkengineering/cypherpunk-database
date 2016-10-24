# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/acct'
require './_framework/http/resource/base'
require './_framework/thirdparty/stripe'

wiz.package 'cypherpunk.backend.account.register'

class cypherpunk.backend.account.register.signup extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	handler: (req, res) => #{{{

		return res.send 400, 'missing parameters' unless req.body?.email?
		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.email_valid(req.body.email)

		@server.root.api.user.database.findOneByEmail req, res, req.body.email, (req, res, user) =>

			return res.send 409, 'Email already registered' if user isnt null

			@server.root.api.user.database.signup req, res, false, (user) =>

				return res.send 500, 'Unable to create account' unless user?

				wiz.log.info "Registered new user account for #{user.email}"

				@server.root.sendWelcomeMail user, (sendgridError) =>
					if sendgridError
						wiz.log.err "Unable to send email to #{user.email} due to sendgrid error"
						console.log sendgridError
						return
					wiz.log.info "Sent welcome email to #{user.email}"

				out = @parent.parent.authenticate.password.doUserLogin(req, res, user)
				res.send 202, out
	#}}}

class cypherpunk.backend.account.register.module extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	load: () =>
		# inherit
		super()

		# public account creation api
		@routeAdd new cypherpunk.backend.account.register.signup(@server, this, 'signup', 'POST')

# vim: foldmethod=marker wrap
