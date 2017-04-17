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

		return res.send 400, 'missing parameters' unless req.body?.email?
		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.email_valid(req.body.email)

		@server.root.api.user.database.findOneByEmail req, res, req.body.email, (req, res, user) =>

			return res.send 409, 'Email already registered' if user isnt null

			@server.root.api.user.database.signup req, res, null, (req2, res2, result) =>

				if result instanceof Array
					user = result[0]
				else
					user = result

				return res.send 500, 'Unable to create account' unless user?.data?.email?

				wiz.log.info "Registered new user account for #{user.data.email}"

				@server.root.sendgrid.sendWelcomeMail user, (sendgridError) =>
					if sendgridError
						wiz.log.err "Unable to send email to #{user.data.email} due to sendgrid error"
						console.log sendgridError
						return
					wiz.log.info "Sent welcome email to #{user.data.email}"

				out = @parent.parent.doUserLogin(req, res, user)
				res.send 202, out
	#}}}

class cypherpunk.backend.api.v0.account.register.teaser extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	handler: (req, res) => #{{{

		return res.send 400, 'missing parameters' unless req.body?.email?
		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.email_valid(req.body.email)

		@server.root.api.user.database.findOneByEmail req, res, req.body.email, (req, res, user) =>

			return res.send 409, 'Email already registered' if user isnt null

			@server.root.api.user.database.teaser req, res, null, (req2, res2, result) =>

				if result instanceof Array
					user = result[0]
				else
					user = result

				return res.send 500, 'Unable to create account' unless user?.data?.email?

				wiz.log.info "Registered new user account for #{user.data.email}"

				@server.root.sendgrid.sendTeaserMail user, (sendgridError) =>
					if sendgridError
						wiz.log.err "Unable to send email to #{user.data.email} due to sendgrid error"
						console.log sendgridError
						return
					wiz.log.info "Sent welcome email to #{user.data.email}"

				out = @parent.parent.doUserLogin(req, res, user)
				res.send 202, out
	#}}}

class cypherpunk.backend.api.v0.account.register.teaserShare extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	handler: (req, res) => #{{{

		return res.send 400, 'missing parameters' unless req.body?.email?
		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.email_valid(req.body.email)

		@server.root.api.user.database.findOneByEmail req, res, req.body.email, (req, res, user) =>

			return res.send 409, 'Email already registered' if user isnt null

			@server.root.api.user.database.teaser req, res, null, (req2, res2, result) =>

				if result instanceof Array
					user = result[0]
				else
					user = result

				return res.send 500, 'Unable to create account' unless user?.data?.email?

				wiz.log.info "Registered new user account for #{user.data.email}"

				if req.body?.name?.length > 0

					@server.root.sendgrid.sendTeaserShareWithFriendMail user, req.body.name, (sendgridError) =>
						if sendgridError
							wiz.log.err "Unable to send email to #{user.data.email} due to sendgrid error"
							console.log sendgridError
							return
						wiz.log.info "Sent welcome email to #{user.data.email}"

				else

					@server.root.sendgrid.sendTeaserShareWithFriendNoNameMail user, (sendgridError) =>
						if sendgridError
							wiz.log.err "Unable to send email to #{user.data.email} due to sendgrid error"
							console.log sendgridError
							return
						wiz.log.info "Sent welcome email to #{user.data.email}"

				out = @parent.parent.doUserLogin(req, res, user)
				res.send 202, out
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
