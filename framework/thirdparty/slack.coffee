require '..'
require '../http/client/base'

crypto = require 'crypto'
util = require 'util'

wiz.package 'wiz.framework.thirdparty.slack'

class wiz.framework.thirdparty.slack
	class httpreq extends wiz.framework.http.client.base

	debug: true

	constructor: (@server, @parent) -> #{{{
	#}}}
	baseRequestOptions: #{{{
		# https://hooks.slack.com
		host: "hooks.slack.com"
	#}}}

	notify: (text, cb) => #{{{
		reqBody =
			text: text

		# build query options
		reqopts = @baseRequestOptions
		reqopts.method = "POST"
		reqopts.path = @webhook
		reqopts.headers =
			"User-Agent" : "CypherpunkBackend/1.0"

		# send query
		q = new httpreq(reqopts)
		q.query reqBody, (res) =>
			# validate response
			console.log res
			return
			state = res.body?
			if not state?
				return res.send 500, "Invalid response from Slack API request"

			return cb(state) if cb
	#}}}

# vim: foldmethod=marker wrap
