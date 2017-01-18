require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

wiz.package 'cypherpunk.backend.api.v0.account.source.default'

class cypherpunk.backend.api.v0.account.source.default extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.free
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.refresh
	nav: false

	handler: (req, res) =>
		# validate default_source param
		return res.send 400, 'missing parameters' unless (req.body?.default_source?)
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.default_source is 'string'

		# get default_source param
		defaultSource = req.body.default_source

		# if stripe customer id exists, proceed to update
		return @parent.stripeSourceUpdateDefault(req, res, defaultSource) if req.session?.account?.data?.stripeCustomerID?

		# otherwise create one first
		return @parent.stripeCustomerCreate req, res, (req, res) =>
			@stripeSourceUpdateDefault(req, res, defaultSource)

# vim: foldmethod=marker wrap
