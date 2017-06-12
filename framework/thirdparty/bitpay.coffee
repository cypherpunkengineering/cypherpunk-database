require '..'
require '../http/client/base'

crypto = require 'crypto'
util = require 'util'

wiz.package 'wiz.framework.thirdparty.bitpay'

class wiz.framework.thirdparty.bitpay
	class httpreq extends wiz.framework.http.client.base

	debug: true

	constructor: (@server, @parent) -> #{{{
	#}}}
	baseRequestOptions: #{{{
		#host: "ipnpb.bitpay.com"
		host: "ipnpb.sandbox.bitpay.com"
	#}}}

	verify: (req, res, args, cb) => #{{{
		console.log req.headers
		console.log req.body
		data = req.body
		if data
			@onVerify(data) if @onVerify
		return res.send 200

		# build query options
		reqopts = @baseRequestOptions
		reqopts.method = "POST"
		reqopts.path = "#{bitpay}/cgi-bin/webscr"
		reqopts.headers =
			"User-Agent" : "CypherpunkBackend/1.0"
			"Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8"

		# send query
		q = new httpreq(reqopts)
		q.query reqBody, (res2) =>
			# validate response
			state = res2?.body?.foo?
			if not state?
				return res.send 500, "Invalid response from BitPay API request"

			return cb(state) if cb
			# hmm
			return res.send 200
	#}}}

# vim: foldmethod=marker wrap
