# copyright 2013 J. Maurice <j@wiz.biz>

require '..'
require '../http/client/base'
require '../util/strval'

https = require 'https'

wiz.package 'wiz.framework.money.fxrateapi'

class wiz.framework.money.fxrateapi
	class httpreq extends wiz.framework.http.client.base

	debug: true

	fiat: [ #{{{
		"AUD"
		"BRL"
		"CAD"
		"CHF"
		"CNY"
		"EUR"
		"GBP"
		"IDR"
		"ILS"
		"MXN"
		"NOK"
		"NZD"
		"PLN"
		"RON"
		"RUB"
		"SEK"
		"SGD"
		"USD"
		"ZAR"
	] #}}}
	constructor: (args = {}) -> #{{{
		@apiKey = args.apiKey
	#}}}
	baseRequestOptions: #{{{
		host: 'api.bitcoinaverage.com'
	#}}}

	getAllTimeHistory: (args, cb) => #{{{
		# local variables
		res = {}

		# validate args
		if not args or typeof args isnt 'object'
			res.error = 'missing args'
			cb(res) if cb
			return

		if not args.fiat or @fiat.indexOf(args.fiat) == -1
			res.error = 'invalid fiat currency: '+args.fiat
			cb(res) if cb
			return

		# build query options
		reqopts = @baseRequestOptions
		reqopts.path = "/history/#{args.fiat}/per_day_all_time_history.csv"

		# send query
		q = new httpreq(reqopts)
		q.query null, () =>
			data = []
			rawdata = q.res?.body or []
			for row in rawdata when row instanceof Array
				continue unless row[3]?
				continue unless new Date(row[0]).getTime() > 0
				if ts = new Date(new Date(row[0]).getTime() - (new Date().getTimezoneOffset() * 60 * 1000) )
					data.push
						ts: ts # date object
						price: row[3] # average of last prices
			out =
				fiat: args.fiat
				data: data

			cb(out) if cb
	#}}}
	getAddress: (args, cb) => #{{{
		# local variables
		res = {}

		# validate args
		if not args or typeof args isnt 'object'
			res.error = 'invalid args'
			cb(res) if cb
			return

		if not wiz.framework.util.strval.validate('int', args.confirmations.toString())
			args.confirmations = 1

		if not wiz.framework.util.strval.validate('btcaddrB58mainnet', args.address)
			res.error = 'invalid bitcoin address'
			cb(res) if cb
			return

		# build query options
		reqopts = @baseRequestOptions
		reqopts.path = '/address/' + args.address
		reqopts.path += '?format=json'
		reqopts.path += '&confirmations=' + args.confirmations
		reqopts.path += '&api_key=' + @apiKey if @apiKey

		# send query
		q = new httpreq(reqopts)
		q.query null, () =>
			res = q.res.body
			cb(res)
	#}}}

# vim: foldmethod=marker wrap
