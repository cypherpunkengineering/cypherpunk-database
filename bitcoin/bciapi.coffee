# copyright 2013 J. Maurice <j@wiz.biz>

require '..'
require '../http/client/base'
require '../util/strval'

https = require 'https'

wiz.package 'wiz.framework.bitcoin.bciapi'

class wiz.framework.bitcoin.bciapi
	class httpreq extends wiz.framework.http.client.base

	debug: true

	constructor: (args = {}) -> #{{{
		@apiKey = args.apiKey
	#}}}
	baseRequestOptions: #{{{
		host: 'blockchain.info'
	#}}}

	getReceivedByAddress: (args, cb) => #{{{
		# local variables
		res = {}

		# validate args
		if not args or typeof args isnt 'object'
			res.err = 'missing args'
			cb(res) if cb
			return

		if not wiz.framework.util.strval.validate('int', args.confirmations.toString())
			args.confirmations = 1

		if not wiz.framework.util.strval.validate('btcaddrB58mainnet', args.address)
			res.err = 'invalid bitcoin address: '+args.address
			cb(res) if cb
			return

		# build query options
		reqopts = @baseRequestOptions
		reqopts.path = '/q/getreceivedbyaddress/' + args.address
		reqopts.path += '?confirmations=' + args.confirmations
		reqopts.path += '&api_key=' + @apiKey if @apiKey

		# send query
		q = new httpreq(reqopts)
		q.query null, () =>
			res = q.res.body
			out =
				address: args.address
				confirmations: args.confirmations

			wiz.log.debug "getReceivedByAddress(#{args.address}, #{args.confirmations}) query response #{res}" if @debug

			if isNaN(res)
				out.err = err = 'invalid response received: '+res
				wiz.log.err(err)
			else
				out.totalReceived = res

			cb(out) if cb
	#}}}
	getAddress: (args, cb) => #{{{
		# local variables
		res = {}

		# validate args
		if not args or typeof args isnt 'object'
			res.err = 'invalid args'
			cb(res) if cb
			return

		if not wiz.framework.util.strval.validate('int', args.confirmations.toString())
			args.confirmations = 1

		if not wiz.framework.util.strval.validate('btcaddrB58mainnet', args.address)
			res.err = 'invalid bitcoin address'
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
			res = {}
			res.data = q.res?.body or {}

			# validate res
			if not res or typeof res isnt 'object'
				res.err = 'invalid response'
				cb(res) if cb
				return

			cb(res)
	#}}}

# vim: foldmethod=marker wrap
