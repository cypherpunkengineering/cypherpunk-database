require '..'

Stripe = require 'stripe'

wiz.package 'wiz.framework.thirdparty.stripe'

class wiz.framework.thirdparty.stripe
	Stripe: null

	@currencies: [ # {{{
		'AED'
		'ARS'
		'AUD'
		'BRL'
		'CAD'
		'CLP'
		'COP'
		'CZK'
		'EUR'
		'GBP'
		'HKD'
		'HUF'
		'IDR'
		'ILS'
		'INR'
		'ISK'
		'JPY'
		'KRW'
		'MAD'
		'MXN'
		'MYR'
		'NZD'
		'PAB'
		'PEN'
		'PHP'
		'PKR'
		'PLN'
		'RON'
		'RUB'
		'SEK'
		'TRY'
		'UAH'
		'USD'
		'VEF'
		'VND'
	] # }}}

	constructor: (@options) ->
		@Stripe = Stripe @options.apiKey

	init: () =>
		# nothing

	getInstance: () =>
		@Stripe

	customerCreate: (req, res, cb) => #{{{
		console.log 'customerCreate'
		stripeArgs =
			email: req.session?.account?.data?.email
		req.server.root.Stripe.customers.create stripeArgs, (stripeError, stripeCustomerData) =>
			return @onError(req, res, stripeError) if stripeError
			return res.send 500, "Unable to call stripe API" if stripeError
			req.session.account.data.stripeCustomerID = stripeCustomerData?.id
			req.server.root.api.user.database.updateCurrentUserData req, res, cb
	#}}}
	sourceAdd: (req, res, source) => #{{{
		console.log 'sourceAdd'
		# get stripe customer ID from session
		stripeCustomerID = req.session?.account?.data?.stripeCustomerID

		# prepare args for stripe
		stripeArgs =
			source: source

		# add source using stripe API
		req.server.root.Stripe.customers.createSource stripeCustomerID, stripeArgs, (stripeError, stripeCustomerData) =>
			# handle error
			return @onError(req, res, stripeError) if stripeError or not stripeCustomerData?.id?

			# get id of newly added card
			defaultSource = stripeCustomerData?.id

			# get updated list of sources
			req.server.root.Stripe.customers.retrieve stripeCustomerID, (stripeError, stripeCustomerData) =>

				# check for error
				return @onError(req, res, stripeError) if stripeError

				# construct list of old source IDs to delete
				sourcesToDelete = []
				if stripeCustomerData?.sources?.data?
					for datum in stripeCustomerData?.sources?.data
						sourcesToDelete.push(datum?.id)

				# delete old cards
				for cardID in sourcesToDelete when cardID != defaultSource
					console.log "Deleting old #{cardID}"
					req.server.root.Stripe.customers.deleteCard stripeCustomerID, cardID, (stripeError, stripeCustomerData) =>

				# update customer object to use new source id as default_source
				@sourceUpdateDefault(req, res, defaultSource)
	#}}}
	sourceUpdateDefault: (req, res, defaultSource) => #{{{
		console.log 'sourceUpdateDefault'
		# get stripe customer ID from session
		stripeCustomerID = req.session?.account?.data?.stripeCustomerID

		# prepare args for stripe
		stripeArgs =
			default_source: defaultSource

		# update customer object's default source using stripe API
		req.server.root.Stripe.customers.update stripeCustomerID, stripeArgs, (stripeError, stripeCustomerData) =>
			# check for error
			return @onError(req, res, stripeError) if stripeError or not stripeCustomerData?.id?

			# respond with freshly updated list of sources
			@sourceList(req, res)
	#}}}
	sourceList: (req, res) => #{{{
		console.log 'sourceList'
		# get stripe customer ID from session
		stripeCustomerID = req.session?.account?.data?.stripeCustomerID

		# retrieve customer object from stripe API
		req.server.root.Stripe.customers.retrieve stripeCustomerID, (stripeError, stripeCustomerData) =>
			# check for error
			return @onError(req, res, stripeError) if stripeError or not stripeCustomerData?.id?

			# construct output object
			out =
				default_source: stripeCustomerData?.default_source
				sources: []

			# add only certain data from each source
			if stripeCustomerData?.sources?.data?
				for datum in stripeCustomerData?.sources?.data
					out.sources.push
						id: datum?.id
						brand: datum?.brand
						last4: datum?.last4
						exp_month: datum?.exp_month
						exp_year: datum?.exp_year

			res.send 200, out
	#}}}
	onError: (req, res, stripeError) => #{{{
		switch stripeError?.type
			when 'StripeCardError' # A declined card error
				out =
					code: stripeError?.code
					statusCode: stripeError?.statusCode
					message: stripeError?.message
				console.log out
				res.send 402, out # => e.g. "Your card's expiration year is invalid."
			when 'RateLimitError' # Too many requests made to the API too quickly
				res.send 500
			when 'StripeInvalidRequestError' # Invalid parameters were supplied to Stripe's API
				res.send 500
			when 'StripeAPIError' # An error occurred internally with Stripe's API
				res.send 500
			when 'StripeConnectionError' # Some kind of error occurred during the HTTPS communication
				res.send 500
			when 'StripeAuthenticationError' # You probably used an incorrect API key
				res.send 500
			else # Handle any other types of unexpected errors
				res.send 500
				break

	#}}}

# vim: foldmethod=marker wrap
