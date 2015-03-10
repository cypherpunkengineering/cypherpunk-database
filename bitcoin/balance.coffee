require '..'

https = require 'https'

wiz.package 'wiz.framework.bitcoin'

class wiz.framework.bitcoin.query

	@baseOptions:
		method: 'GET'
		hostname: 'blockchain.info'
		port: 443

	@query: (options, cb) ->
		req = https.request options, (res) ->
			res.on 'data', (d) ->
				wiz.log.debug "bitcoin query response #{d}"
				cb(d)
				return
			return

		req.end()
		req.on 'error', (e) ->
			wiz.log.error "bitcoin query error: #{e}"
			cb(null)

	@getReceivedByAddress: (addr, confirmations = 5, cb = null) ->
		options = wiz.framework.bitcoin.query.baseOptions
		options.path = '/q/getreceivedbyaddress/' + addr
		options.path += '?confirmations=' + confirmations if confirmations
		@query options, (d) ->
			wiz.log.debug "getReceivedByAddress(#{addr}, #{confirmations}) = #{d}"
			cb(d) if cb

#wiz.framework.bitcoin.query.getReceivedByAddress '1MVEfs8QLgLWZbHF62rjy7qnjHR4Bfe3MY', 5, (d) ->
#	console.log d.toString()
