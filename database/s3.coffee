# copyright 2013 wiz technologies inc.

require '..'

crypto = require 'crypto'
xml2js = require 'xml2js'
stream = require 'stream'
https = require 'https'
http = require 'http'

wiz.package 'wiz.framework.database.s3'

class wiz.framework.database.s3

	constructor: (options) -> #{{{

		options ?= {}

		# for testing
		#options.key ?= ''
		#options.secret ?= ''

		wiz.assert (@key = options.key), 'S3 key'
		wiz.assert (@secret = options.secret), 'S3 secret'

		wiz.assert (@host = options.host || 's3.wiz.biz'), 'S3 host'
		wiz.assert (@port = options.port || 8080), 'S3 port'

		wiz.assert (@adminHost = options.adminHost || 's3.wiz.biz'), 'S3 adminHost'
		wiz.assert (@adminPort = options.adminPort || 8000), 'S3 adminPort'

		@ssl = if options.ssl is true then true else false
	#}}}

	client: () => # to ssl or not to ssl {{{
		return (if @ssl is false then http else https)
	#}}}
	opts: (method, bucket, path, contentType, reqLen) => # generate signed request #{{{

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

		# build URI path
		delim = '/'
		resource = delim
		resource += bucket if bucket
		resource += delim if path[0] and path[0] != delim
		resource += path if resource != delim

		params = ''
		params += "?delimeter=#{delim}" if bucket

		headers = {}

		# set request options
		opts =
			method: method
			path: resource + params
			host: @host
			port: @port
			headers: JSON.parse(JSON.stringify(headers))

		# set request headers
		opts.headers['Host'] = @host
		opts.headers['Date'] = ts.toUTCString()
		opts.headers['Content-Type'] = contentType if contentType
		opts.headers['Content-Length'] = reqLen if reqLen
		opts.headers['Authorization'] = @sign(ts.toUTCString(), method, headers, resource, contentType)

		return opts

	#}}}
	optsAdmin: (opts) => # set opts to use admin host/port #{{{
		opts.host = @adminHost
		opts.port = @adminPort
		return opts
	#}}}
	sign: (ts, method, headers, resource, contentType = '', contentMD5 = '') => #{{{
		hdrcat = ("#{x.toLowerCase()}:#{y}" for x, y of headers).join('\n')
		hdrcat += '\n' if hdrcat != ''
		reqStr = [
			method
			contentMD5
			contentType
			ts
			hdrcat + resource
		].join('\n')
		#console.log hdrcat
		#console.log reqStr
		sig = crypto.createHmac('sha1', @secret).update(reqStr).digest('base64')
		return "AWS #{@key}:#{sig}"
	#}}}
	error: (e, cb) => #{{{
		wiz.log.err e
		return cb null if cb
		return null
	#}}}

	reqCreate: (opts, parse, cb) => #{{{ create request
		# debug print
		#console.log "#{opts.method} #{opts.path} HTTP/1.1"
		#console.log ("#{x}: #{y}" for x, y of opts.headers).join('\n')
		#console.log ''

		# create request
		req = @client().request opts, (res) =>
			#TODO: move this all into one leet reqParse method

			return @error 'no response!', cb if not res

			switch res.statusCode
				when 400, 403, 404, 405, 500, 502, 503
					@error "HTTP #{res.statusCode}", cb

				else
					return @resParse res, cb if parse
					return cb res

		return req
	#}}}
	reqSend: (req, reqBody = null) => #{{{ send request

		# set request error handler
		req.on 'error', (e) =>
			@error e

		if not reqBody

			req.end()

		else if reqBody instanceof String or typeof reqBody is 'string'

			req.end reqBody

		else if reqBody instanceof Buffer

			req.end reqBody

		else if reqBody instanceof stream.Readable

			req.pipe reqBody

		else if reqBody instanceof Object or typeof reqBody is 'object'

			req.end JSON.stringify(reqBody)

		else

			wiz.log.err 'Cannot send unknown reqBody type: '+typeof reqBody
			req.end()
	#}}}
	resParse: (res, cb) => # parse a json or xml response {{{
		res.setEncoding('utf8')
		res.on 'data', (datum) =>
			switch res.headers['content-type']

				when 'application/json'

					try
						out = JSON.parse datum
					catch e
						return @error "json parse error: #{e}", cb

					return cb out

				when 'application/xml'

					try
						parser = new xml2js.Parser()
						parser.parseString datum, (err, out) =>
							if err
								return @error "xml parse error: #{err}", cb
							if not out
								return @error "xml response null?", cb
							if out.Error
								return @error "xml error response! #{JSON.stringify(out.Error)}", cb
							return cb out
					catch e
						return @error "xml parse error: #{e}", cb

				else

					wiz.log.err 'unknown content type: '+res.headers['content-type']
	#}}}

	issueCredentials: (name, email, userKey = null, cb) => # user management {{{
		reqBody =
			name: name
			email: email

		path = '/user/'

		if userKey # reset credentials
			path += userKey
			reqBody.new_key_secret = true

		opts = @optsAdmin @opts('POST', 'riak-cs', path, 'application/json', 0)
		req = @reqCreate opts, true, (res) =>
			cb res
		@reqSend req, reqBody
	#}}}

	createNewBucket: (bucket, cb) => # create a new bucket {{{
		wiz.assert bucket, 'bucket name'
		@reqSend @reqCreate(@opts('PUT', bucket, '/', null, null, 0), false, cb)
	#}}}
	deleteEmptyBucket: (bucket, cb) => # delete an empty bucket {{{
		wiz.assert bucket, 'bucket name'
		@reqSend @reqCreate(@opts('DELETE', bucket, '/', null, null, 0), true, cb)
	#}}}
	listAllMyBuckets: (cb) => # list all my buckets {{{
		req = @reqCreate @opts('GET', null, '/', null, null, 0), true, (res) =>
			b = res?.ListAllMyBucketsResult?.Buckets
			if b and b instanceof Array and b[0] and b[0].Bucket
				buckets = b[0].Bucket
				return cb buckets
		@reqSend req
	#}}}
	listBucketContents: (bucket, path = '/', cb) => # list objects in a bucket with given path {{{
		wiz.assert bucket, 'bucket name'
		req = @reqCreate @opts('GET', bucket, path, null, null, 0), true, (res) =>
			c = res?.ListBucketResult?.Contents
			if c and c instanceof Array
				return cb c
			else
				return cb []
		@reqSend req
	#}}}

	putStream: (bucket, path, file, cb) => # store stream as object in bucket {{{
		wiz.assert bucket, 'bucket name'
		@reqSend @reqCreate(@opts('PUT', bucket, path, null, 0), true, cb), file
	#}}}
	getParse: (bucket, path, cb) => # get metadata about bucket {{{
		wiz.assert bucket, 'bucket name'
		@reqSend @reqCreate(@opts('GET', bucket, path, null, 0), true, cb)
	#}}}
	getStream: (bucket, path, cb) => # get object from bucket {{{
		wiz.assert bucket, 'bucket name'
		req = @reqCreate @opts('GET', bucket, path, null, 0), false, cb
		@reqSend req
	#}}}
	deleteOne: (bucket, path, cb) => # delete object from bucket {{{
		wiz.assert bucket, 'bucket name'
		@reqSend @reqCreate(@opts('DELETE', bucket, path, null, 0), true, cb), file
	#}}}

# vim: foldmethod=marker wrap
