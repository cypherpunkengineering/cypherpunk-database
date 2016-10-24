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
		@server.root.api.user.database.findOneByID req, res, req.body.email, (req, res, user) =>
			if user?
				res.send 409, 'Account Already Exists'
				return

			@server.root.api.user.database.signup req, res, (result) =>
				if result is null
					wiz.log.err 'Unable to signup user!'
					res.send 500, 'Error creating account'
					return

				@server.root.sendWelcomeMail args.email, (sendgridError) =>
					if sendgridError
						wiz.log.err "Unable to send email to #{args.email} due to sendgrid error"
						console.log sendgridError
					res.send 202, 'Account Created'
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
