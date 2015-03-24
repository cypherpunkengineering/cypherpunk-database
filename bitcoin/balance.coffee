require '..'
require '../util/strval'

https = require 'https'

wiz.package 'wiz.framework.bitcoin'

class wiz.framework.bitcoin.query

	@baseRequestOptions:
		method: 'GET'
		hostname: 'blockchain.info'
		port: 443

	@query: (reqopts, cb) ->
		req = https.request reqopts, (res) ->
			res.on 'data', (d) ->
				#wiz.log.debug "bitcoin query response #{d}"
				cb(d)
				return
			return

		req.end()
		req.on 'error', (e) ->
			wiz.log.error "bitcoin query error: #{e}"
			cb(null)

	@getReceivedByAddress: (args, cb) ->
		res = {}

		if not args or typeof args isnt 'object'
			res.error = 'invalid args'
			cb(res) if cb
			return

		if not wiz.framework.util.strval.validate('int', args.confirmations)
			args.confirmations = 1

		if not wiz.framework.util.strval.validate('btcaddrB58mainnet', args.address)
			res.error = 'invalid bitcoin address'
			cb(res) if cb
			return

		reqopts = @baseRequestOptions
		reqopts.path = '/q/getreceivedbyaddress/' + args.address
		reqopts.path += '?confirmations=' + args.confirmations
		reqopts.path += '&api_key=' + args.apiKey if args.apiKey

		@query reqopts, (sats) ->
			res =
				address: args.address
				confirmations: args.confirmations
			#wiz.log.debug "getReceivedByAddress(#{args.address}, #{args.confirmations}) = #{sats}"
			if isNaN(sats)
				res.err = err = 'invalid response received: '+sats
				wiz.log.err(err)
			else
				res.balance = sats

			cb(res) if cb

#wiz.framework.bitcoin.query.getReceivedByAddress '1MVEfs8QLgLWZbHF62rjy7qnjHR4Bfe3MY', 5, (d) ->
#	console.log d.toString()
