# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../base'
require '../middleware'

stream = require 'stream'
https = require 'https'
http = require 'http'

wiz.package 'wiz.framework.http.client'

class wiz.framework.http.client.base extends wiz.framework.http.base
	debug: true
	middleware: wiz.framework.http.middleware.base

	constructor: (args = {}) -> #{{{ parse request args

		@ssl = if args.ssl is false then false else true
		wiz.assert (@host = args.host), 'http query host'
		wiz.assert (@port = args.port || 443), 'http query port'
		wiz.assert (@method = args.method || 'GET'), 'http query method'
		wiz.assert (@path = args.path || '/'), 'http query path'
		@headers = args.headers if args?.headers?

	#}}}

	# to ssl or not to ssl
	client: () => #{{{ http or https object
		return (if @ssl is false then http else https)
	#}}}
	proto: () => #{{{ http or http string
		(if @ssl is false then 'http' else 'https')
	#}}}

	error: (e, cb) => #{{{ error handler
		wiz.log.err e
		return cb null if cb
		return null
	#}}}

	query: (body = null, cb) => #{{{ create and send request
		# create options object
		@reqOpts(body, cb)

		# debug print
		console.log "#{@opts.method} #{@opts.path} HTTP/1.1" if @debug
		console.log ("#{x}: #{y}" for x, y of @opts.headers).join('\n') if @debug
		console.log '' if @debug
		console.log body if @debug

		# create request
		@req = @client().request @opts, (res) =>
			@onResponse(res, cb)

		# set request error handler
		@req.on 'error', (e) =>
			@error e, cb

		# send request body
		@reqSend(body, cb)
	#}}}

	reqOpts: (body, cb) => #{{{ build request options
		# timestamp the request
		@ts = new Date()

		# set request opts
		@opts =
			method: @method
			host: @host
			port: @port
			path: @path

		# set request headers
		@opts.headers ?= @headers or {}
		@opts.headers['Host'] ?= @host
		@opts.headers['Accept'] ?= 'application/json'
		@opts.headers['Content-Type'] ?= 'application/json' if @method is 'POST'
		@opts.headers['Content-Length'] ?= if body then body.length else 0
	#}}}
	reqSend: (reqBody, cb) => #{{{ send request body
		if not reqBody
			@req.end()
		else if reqBody instanceof String or typeof reqBody is 'string'
			@req.end(reqBody)
		else if reqBody instanceof Buffer
			@req.end(reqBody)
		else if reqBody instanceof stream.Readable
			@req.pipe(reqBody)
		else if reqBody instanceof Object or typeof reqBody is 'object'
			@req.end JSON.stringify(reqBody)
		else
			wiz.log.err 'Cannot send unknown reqBody type: '+typeof reqBody
			@req.end()
	#}}}
	fakeres:
		send: (n, err) =>
			console.log(err)

	onResponse: (@res, cb) => #{{{ parse response
		return @error 'no response!', cb unless @res

		console.log @res.statusCode if @debug
		console.log @res.headers if @debug

		switch @res.statusCode
			when 400, 403, 404, 405, 500, 502, 503
				@middleware.parseBodyByCT(@res, @fakeres, cb)
				@error "HTTP #{@res.statusCode}", cb
				console.log @res.body if @debug
			else
				@middleware.parseBodyByCT(@res, @fakeres, cb)
	#}}}

# vim: foldmethod=marker wrap
