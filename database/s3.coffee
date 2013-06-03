# copyright 2013 wiz technologies inc.

require '..'

crypto = require 'crypto'
xml2js = require 'xml2js'
https = require 'https'
http = require 'http'

wiz.package 'wiz.framework.database.s3'

class wiz.framework.database.s3

	constructor: (options) -> #{{{

		options ?= {}

		@key = options.key
		@secret = options.secret

		@host = options.host || 's3.wiz.biz'
		@port = options.port || 443

		@adminHost = options.adminHost || 's3.wiz.biz'
		@adminPort = options.adminPort || 8000

		@ssl = if options.ssl is false then false else true

		@defaultHeaders =
			'Host': options.headerHost || @host
	#}}}

	req: (method, path, contentType, reqBody, cb) => #{{{

		# Example S3 query to create a user:
		#
		# POST http://s3.wiz.biz/riak-cs/user HTTP/1.1
		# Host: s3.wiz.biz
		# Date: Sun, 24 Feb 2013 11:16:12 +0000
		# Authorization: AWS 963SKIBE-6TRMWDQAW3P:qvODgCwpDJNEXwB9pZ3n2o1FlhY=
		# Content-Type: application/json
		# Content-Length: 44
		#
		# {'email':'test@wiz.biz', 'name':'test user'}

		# timestamp the request
		ts = new Date()

		# set request options
		opts =
			method: method
			path: path
			host: @host
			port: @port
			headers: @defaultHeaders

		# set request headers
		opts.headers['Date'] = ts.toUTCString()
		opts.headers['Content-Type'] = contentType if contentType
		opts.headers['Content-Length'] = reqBody.length if reqBody
		opts.headers['Authorization'] = @sign(ts, method, path, contentType)

		# to ssl or not ssl
		protocol = if @ssl is false then http else https

		# create request
		req = protocol.request opts, cb
		req.on 'error', (e) =>
			@error e, cb

		if reqBody instanceof String
			body = reqBody
		else if reqBody instanceof Buffer
			body = reqBody.toString()
		else if reqBody instanceof Object
			body = JSON.stringify(reqBody)

		req.write body
		req.end()
	#}}}
	sign: (ts, method, path, contentType) => #{{{
		reqStr = "#{method}\n\n#{contentType}\n#{ts.toUTCString()}\n#{path}"
		sig = crypto.createHmac('sha1', @secret).update(reqStr).digest('base64')
		return "AWS #{@key}:#{sig}"
	#}}}
	error: (e, cb) => #{{{
		wiz.log.err "http error: #{e}"
		return cb null if cb
		return null
	#}}}
	response: (res, cb) => #{{{
		return @error 'no response', cb if not res
		res.setEncoding('utf8')
		res.on 'data', (datum) =>

			if not res.statusCode == 200
				return @error "bad response #{res.statusCode}", cb

			if not datum or not res.headers or not res.headers['content-type']
				return @error 'invalid response', cb

			switch res.headers['content-type']

				when 'application/json'
					try
						out = JSON.parse datum
						return cb out
					catch e
						return @error "json parse error: #{e}", cb

				when 'application/xml'
					parser = new xml2js.Parser()
					parser.parseString datum, (err, out) =>
						return @error "xml parse error: #{err}", cb if err or not out
						return cb out

				else
					wiz.log.err "unknown response type #{res.headers['content-type']}"
					console.log datum
					return cb null
	#}}}

	listBuckets: (cb) => #{{{
		@req 'GET', '/', '', null, (res) =>
			@response res, cb
	#}}}
	issueCredentials: (name, email, userKey = null, cb) => #{{{

		reqBody =
			name: name
			email: email

		path = '/riak-cs/user/'

		if userKey # reset credentials
			path += userKey
			reqBody.new_key_secret = true

		@req 'POST', path, 'application/json', reqBody, (res) =>
			@response res, cb
	#}}}

# vim: foldmethod=marker wrap
