require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require './add'
require './default'
require './list'

wiz.package 'cypherpunk.backend.api.v0.account.source'

class cypherpunk.backend.api.v0.account.source.resource extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.free
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.refresh
	nav: false

	stripeCustomerCreate: (req, res, cb) => #{{{
		stripeArgs =
			email: req.session?.account?.data?.email
		req.server.root.Stripe.customers.create stripeArgs, (stripeError, stripeCustomerData) =>
			console.log stripeError if stripeError
			return res.send 500, "Unable to call stripe API" if stripeError
			req.session.account.data.stripeCustomerID = stripeCustomerData?.id
			req.server.root.api.user.database.updateCurrentUserData req, res, cb
	#}}}
	stripeSourceAdd: (req, res, source) => #{{{
		# get stripe customer ID from session
		stripeCustomerID = req.session?.account?.data?.stripeCustomerID

		# prepare args for stripe
		stripeArgs =
			source: source

		# add source using stripe API
		req.server.root.Stripe.customers.createSource stripeCustomerID, stripeArgs, (stripeError, stripeCustomerData) =>
			if stripeError or not stripeCustomerData?.id?
				wiz.log.err "Unable to add source for customer"
				console.log stripeError
				res.send 500, "Unable to add source"
				return

			# get id of newly added card
			defaultSource = stripeCustomerData?.id

			# update customer object to use new source id as default_source
			@stripeSourceUpdateDefault(req, res, defaultSource)
	#}}}
	stripeSourceUpdateDefault: (req, res, defaultSource) => #{{{
		# get stripe customer ID from session
		stripeCustomerID = req.session?.account?.data?.stripeCustomerID

		# prepare args for stripe
		stripeArgs =
			default_source: defaultSource

		# update customer object's default source using stripe API
		req.server.root.Stripe.customers.update stripeCustomerID, stripeArgs, (stripeError, stripeCustomerData) =>

			if stripeError
				wiz.log.err "Unable to update default source for customer"
				console.log stripeError
				res.send 500, "Unable to update default source"
				return

			# respond with freshly updated list of sources
			@stripeSourceList(req, res)
	#}}}
	stripeSourceList: (req, res) => #{{{
		# get stripe customer ID from session
		stripeCustomerID = req.session?.account?.data?.stripeCustomerID

		# retrieve customer object from stripe API
		req.server.root.Stripe.customers.retrieve stripeCustomerID, (stripeError, stripeCustomerData) =>

			if stripeError?
				wiz.log.err "Unable to update default source for customer"
				console.log stripeError
				res.send 500, "Unable to update default source"
				return

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

	load: () =>
		# inherit
		super()

		# public account creation api
		@routeAdd new cypherpunk.backend.api.v0.account.source.add(@server, this, 'add', 'POST')
		@routeAdd new cypherpunk.backend.api.v0.account.source.default(@server, this, 'default', 'POST')
		@routeAdd new cypherpunk.backend.api.v0.account.source.list(@server, this, 'list')

# vim: foldmethod=marker wrap
