require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

require './_framework/thirdparty/stripe'
require './_framework/thirdparty/sendgrid'

wiz.package 'cypherpunk.backend.api.v0.account.purchase.stripe'

class cypherpunk.backend.api.v0.account.purchase.stripe extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	handler: (req, res) => #{{{
		# validate params
		return res.send 400, 'missing parameters' unless (req.body?.email?)
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.email is 'string'
		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.email_valid(req.body.email)

		# nuke existing session if any
		wiz.framework.http.account.session.logout(req, res)

		# check if account already exists on given email address
		@server.root.api.user.database.findOneByEmail req, res, req.body.email, (req, res, user) =>

			# if so, return error
			return res.send 409, 'Email already registered' if user isnt null

			# proceed to actual stripe purchase
			req.server.root.stripe.purchase(req, res)
	#}}}

# vim: foldmethod=marker wrap
