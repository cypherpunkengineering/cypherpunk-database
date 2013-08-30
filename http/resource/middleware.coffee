# copyright 2013 wiz technologies inc.

require '../..'
require '../../util/strval'

qs = require 'qs'
formidable = require 'formidable'

wiz.package 'wiz.framework.http.resource'

class wiz.framework.http.resource.middleware

	@parseIP: (req, res) => #{{{
		req.ip = wiz.framework.util.strval.inet6_prefix_trim(req?.connection?.remoteAddress or '0.0.0.0')
		req.next()
	#}}}
	@parseHostHeader: (req, res) => #{{{ parse Host header
		try
			req.host = req.headers.host.split(':')[0]
		catch e
			req.host = ''

		return req.next() if wiz.framework.util.strval.validate('fqdnDot', req.host)
		return req.next() if wiz.framework.util.strval.validate('inet4', req.host)
		return req.next() if wiz.framework.util.strval.validate('inet6', req.host)

		res.send 400, 'missing or invalid host header'
	#}}}
	@parseURL: (req, res) => #{{{ parse url params and body
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

		req.next()
	#}}}
	@parseCookie: (req, res) => #{{{
		wiz.log.debug "Got cookie: #{req.headers.cookie}" if req.headers?.cookie?
		req.cookie = ''
		req.next()
	#}}}
	@parseBody: (req, res) => #{{{
		# initialize as empty
		req.body = {}

		# dont bother trying to parse for GET/HEAD
		return req.next() if req.method == 'GET'
		return req.next() if req.method == 'HEAD'

		# if multipart/form-data, parse the request body
		switch req?.headers?['content-type']

			when 'application/x-www-form-urlencoded'
				req.setEncoding 'utf8'
				buf = ''
				req.on 'data', (chunk) ->
					buf += chunk
				req.on 'end', () ->
					try
						if buf.length
							req.body = qs.parse(buf)

						req.next()
						return

					catch err
						res.send 400, "error parsing(1) request body", err
						return

			when 'application/json'
				req.setEncoding 'utf8'
				buf = ''
				req.on 'data', (chunk) ->
					buf += chunk
				req.on 'end', () ->
					try
						if buf.length
							req.body = JSON.parse(buf)

						req.next()
						return

					catch err
						res.send 400, "error parsing(2) request body", err
						return

			when 'multipart/form-data'
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
						req.next()
					catch err
						res.send 400, "error parsing(31) request body", err
						return

				form.parse(req)

			else
				# dont know how to parse this content-type
				req.next()
	#}}}

# vim: foldmethod=marker wrap
