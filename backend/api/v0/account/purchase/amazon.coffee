require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

require './_framework/thirdparty/amazon'

wiz.package 'cypherpunk.backend.api.v0.account.purchase.amazon'

class cypherpunk.backend.api.v0.account.purchase.amazon extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	handler: (req, res) =>
		console.log req.body

		# validate params
		return res.send 400, 'missing parameters' unless req.body?.email?
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.email is 'string'
		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.email_valid(req.body.email)

		return res.send 400, 'missing parameters' unless req.body?.password?
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.password is 'string'

		# nuke existing session if any
		wiz.framework.http.account.session.logout(req, res)

		# check if account already exists on given email address
		@server.root.api.user.database.findOneByEmail req, res, req.body.email, (req, res, user) =>

			# if so, return error
			return res.send 409, 'Email already registered' if user isnt null

			# get billing agreement details
			req.server.root.amazon.purchase(req, res)

# vim: foldmethod=marker wrap
