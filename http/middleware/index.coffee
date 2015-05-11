# copyright 2013 J. Maurice <j@wiz.biz>

require '../../'
require '../../util/csv'

qs = require 'qs'
formidable = require 'formidable'

wiz.package 'wiz.framework.http.middleware'

# utility functions for interacting with http req/res objects
class wiz.framework.http.middleware.base
	debug: true
	constructor: () ->

	error: (e, cb) => #{{{ error handler
		wiz.log.err e
		return cb null if cb
		return null
	#}}}

	# header parsing methods
	@parseIP: (req, res, cb) => #{{{
		if req.server.config.behindReverseProxy is true
			req.ip = req.headers['x-forwarded-for']

		req.ip ?= wiz.framework.util.strval.inet6_prefix_trim(req.connection?.remoteAddress or '0.0.0.0')
		return cb()
	#}}}
	@parseHostHeader: (req, res, cb) => #{{{ parse Host header
		try
			req.host = req.headers.host.split(':')[0]
		catch e
			req.host = ''

		return cb() if wiz.framework.util.strval.validate('fqdnDot', req.host)
		return cb() if wiz.framework.util.strval.validate('inet4', req.host)
		return cb() if wiz.framework.util.strval.validate('inet6', req.host)

		res.send 400, 'missing or invalid host header'
	#}}}
	@parseURL: (req, res, cb) => #{{{ parse url params and body
		req.params = {}

		try
			url = req.url
			qm = url.indexOf('?')
			if qm > 0 and qm < url.length
				args = url.slice(qm + 1, url.length)
				req.url = url.slice(0, qm)
				for arg in args.split('&')
					param = arg.split('=')
					x = decodeURIComponent(param[0])
					y = decodeURIComponent(param[1]) or ''
					req.params[x] = y if x? and x isnt '' and y?
		catch e
			wiz.log.err "error parsing url: #{e}"
			res.send 400, "error parsing URL args"
			return

		return cb()
	#}}}
	@parseCookie: (req, res, cb) => #{{{
		#wiz.log.debug "Got cookie: #{req.headers.cookie}" if req.headers?.cookie?

		# only run once
		return cb() if req.cookies?

		# initialize cookie object
		req.cookies = {}

		# make local copy of cookie header
		cookie = req.headers.cookie

		return cb() unless cookie
		try
			obj = {}
			pairs = cookie.split(/[;,] */)

			for i in [0...pairs.length]
				pair = pairs[i]
				eqlIndex = pair.indexOf('=')
				key = pair.substr(0, eqlIndex).trim().toLowerCase()
				val = pair.substr(++eqlIndex, pair.length).trim()

				# quoted values
				if val[0] == '"'
					val = val.slice(1, -1)

				# only assign once
				if obj[key] == undefined
					val = val.replace(/\+/g, ' ')
					try
						obj[key] = decodeURIComponent(val)
					catch err
						if err instanceof URIError
							obj[key] = val
						else
							throw err

			req.cookies = obj
			return cb()

		catch err

			res.send 400, "error parsing cookie", err
			return
	#}}}

	# body parsing methods
	@parseContentType: (req, res) => #{{{
		# separate charset value if present, ie. 'application/x-www-form-urlencoded; charset=UTF-8'
		parts = req.headers?['content-type']?.split(';')
		ct = parts?[0] or null
		return ct
	#}}}
	@parseBodyByCT: (req, res, cb) => #{{{
		ct = @parseContentType(req, res)
		switch ct
			when 'application/json'
				@parseJSON(req, res, cb)
			when 'application/x-www-form-urlencoded'
				@parseFormUrlEncoded(req, res, cb)
			when 'multipart/form-data'
				@parseMultipartFormData(req, res, cb)
			when 'text/html'
				@parseTextHTML(req, res, cb)
			when 'text/plain'
				@parseTextPlain(req, res, cb)
			when 'text/csv'
				@parseTextCSV(req, res, cb)
			when undefined # no ct supplied
				return cb()
			else # unsupported ct
				wiz.log.err 'unknown content type: '+ct
				return cb()
	#}}}
	@parseJSON: (req, res, cb) => #{{{
		req.setEncoding 'utf8'
		buf = ''
		req.on 'data', (chunk) ->
			buf += chunk
		req.on 'end', () ->
			try
				if buf.length
					req.body = JSON.parse(buf)
			catch err
				res.send 400, "error parsing(2) request body", err
				return

			return cb()
	#}}}
	@parseFormUrlEncoded: (req, res, cb) => #{{{
		req.setEncoding 'utf8'
		buf = ''
		req.on 'data', (chunk) ->
			buf += chunk
		req.on 'end', () ->
			try
				if buf.length
					req.body = qs.parse(buf)

				cb()
				return

			catch err
				res.send 400, "error parsing(1) request body", err
				return
	#}}}
	@parseMultipartFormData: (req, res, cb) => #{{{
		form = new formidable.IncomingForm()
		data = {}
		files = {}
		done = undefined

		ondata = (name, val, data) ->
			if (Array.isArray(data[name]))
				data[name].push(val)
			else if (data[name])
				data[name] = [data[name], val]
			else
				data[name] = val

		form.on 'field', (name, val) ->
			ondata(name, val, data)

		form.on 'file', (name, val) ->
			ondata(name, val, files)

		form.on 'error', (err) ->
			done = true
			res.send 400, "error parsing(3) request body", err

		form.on 'end', () ->
			return if done
			try
				req.body = qs.parse(data)
				req.files = qs.parse(files)
				return cb()
			catch err
				res.send 400, "error parsing(31) request body", err
				return

		form.parse(req)
	#}}}
	@parseTextPlain: (req, res, cb) => #{{{
		req.setEncoding 'utf8'
		buf = ''
		req.on 'data', (chunk) ->
			buf += chunk
		req.on 'end', () ->
			req.body = buf
			return cb()
	#}}}
	@parseTextHTML: (req, res, cb) => #{{{
		@parseTextPlain req, res, () => # TODO: implement html parsing
			console.log req.body
			cb()
	#}}}
	@parseTextCSV: (req, res, cb) => #{{{
		req.setEncoding 'utf8'
		buf = ''
		req.on 'data', (chunk) ->
			buf += chunk
		req.on 'end', () ->
			req.body = wiz.framework.util.csv.parse(buf)
			return cb()
	#}}}

# vim: foldmethod=marker wrap
