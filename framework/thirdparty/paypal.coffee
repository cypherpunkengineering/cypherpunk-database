require '..'
require '../http/client/base'

crypto = require 'crypto'
util = require 'util'

wiz.package 'wiz.framework.thirdparty.paypal'

class wiz.framework.thirdparty.paypal
	class httpreq extends wiz.framework.http.client.base

	debug: true

	constructor: (@server, @parent) -> #{{{
	#}}}

	ipn: (req, res) => #{{{
		#console.log req.headers if @debug
		console.log req.body if @debug
		# must send 200 back or paypal will re-deliver IPN data
		# TODO: either use verify_sign or the below verification POST thing
	#}}}
	verifyIPN: (req, res, args, cb) => #{{{
		# build query options
		reqopts =
			method: "POST"
			host: (if wiz.style is 'DEV' then 'ipnpb.paypal.com' else 'ipnpb.sandbox.paypal.com')
			path: "/cgi-bin/webscr"
			headers:
				"User-Agent" : "CypherpunkBackend/1.0"
				"Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8"

		# send query
		q = new httpreq(reqopts)
		q.query reqBody, (res2) =>
			# validate response
			state = res2?.body?.foo?
			if not state?
				return res.send 500, "Invalid response from Paypal API request"

			return cb(state) if cb
			# hmm
			return res.send 200
	#}}}

# vim: foldmethod=marker wrap
