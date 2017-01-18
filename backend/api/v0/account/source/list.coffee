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
		# get stripe customer ID from session
		stripeCustomerID = req.session?.account?.data?.stripeCustomerID
		# if no stripe customer id, just return empty set
		return res.send 200, {} if not stripeCustomerID

		# retrieve customer object from stripe API
		req.server.root.Stripe.customers.retrieve stripeCustomerID, (stripeError, stripeCustomerData) =>

			# construct output object
			out =
				default_source: stripeCustomerData?.default_source
				sources: []

			# add only certain data from each source
			for datum in stripeCustomerData?.sources?.data
				out.sources.push
					id: datum?.id
					brand: datum?.brand
					last4: datum?.last4
					exp_month: datum?.exp_month
					exp_year: datum?.exp_year

			res.send 200, out
	#}}}

# vim: foldmethod=marker wrap
