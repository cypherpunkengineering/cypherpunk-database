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

# vim: foldmethod=marker wrap
