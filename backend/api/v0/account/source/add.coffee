require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

wiz.package 'cypherpunk.backend.api.v0.account.source.add'

class cypherpunk.backend.api.v0.account.source.add extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.free
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.refresh
	nav: false

	handler: (req, res) =>
		# validate source
		return res.send 400, 'missing parameters' unless req.body?.token?
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.token is 'string'

		# get source
		source = req.body.token

		# if stripe customer id exists, proceed to update
		return @parent.stripeSourceAdd(req, res, source) if req.session?.account?.data?.stripeCustomerID?

		# otherwise create one first
		return @parent.stripeCustomerCreate req, res, (req, res) =>
			@stripeSourceAdd(req, res, source)
	#}}}

# vim: foldmethod=marker wrap
