require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

wiz.package 'cypherpunk.backend.api.v0.account.source.list'

class cypherpunk.backend.api.v0.account.source.list extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.free
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.refresh
	nav: false

	handler: (req, res) => #{{{
		# if stripe customer id exists, proceed to update
		return @parent.stripeSourceList(req, res) if req.session?.account?.data?.stripeCustomerID?

		# otherwise create one first
		return @parent.stripeCustomerCreate req, res, (req, res) =>
			@stripeSourceList(req, res)
	#}}}


# vim: foldmethod=marker wrap
