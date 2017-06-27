require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

wiz.package 'cypherpunk.backend.api.v0.account.source.list'

class cypherpunk.backend.api.v0.account.source.list extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.expired
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.refresh
	nav: false

	handler: (req, res) => #{{{
		# if stripe customer id exists, proceed to update
		return req.server.root.stripe.sourceList(req, res) if req.session?.account?.data?.stripeCustomerID?

		# otherwise create one first
		return req.server.root.stripe.customerCreate req, res, (req, res) =>
			req.server.root.stripe.sourceList(req, res)
	#}}}


# vim: foldmethod=marker wrap
