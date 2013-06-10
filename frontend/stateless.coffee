# copyright 2013 wiz technologies inc.

require '..'
require './database'
require './server'
require './util'

wiz.package 'wiz.framework.frontend.stateless'

# node frameworks
coffee = require 'coffee-script'
cluster = require 'cluster'
http = require 'http'
jade = require 'jade'
fs = require 'fs'
os = require 'os'

# server config object
class wiz.framework.frontend.stateless.config extends wiz.framework.frontend.config

# main server class
class wiz.framework.frontend.stateless.server extends wiz.framework.frontend.server

	preModuleCreate: () =>
		@http = http.createServer (req, res, out) =>
			@handle(req, res, out)
		super()

	use: (route, fn) =>

		# default route to '/'
		unless "string" is typeof route
			fn = route
			route = "/"

		# wrap sub-apps
		if "function" is typeof fn.handle
			server = fn
			fn.route = route
			fn = (req, res, next) =>
				server.handle req, res, next

		# wrap vanilla http.Servers
		fn = fn.listeners("request")[0] if fn instanceof http.Server

		# strip trailing slash
		route = route.slice(0, -1) if "/" is route[route.length - 1]

		# add the middleware
		#wiz.log.debug "use #{route} #{fn.name}"
		@stack ?= []
		@stack.push
			route: route
			handle: fn

		return this

	handle: (req, res, out) =>

		stack = @stack
		fqdn = ~req.url.indexOf("://")
		removed = ""
		slashAdded = false
		index = 0

		next = (err) ->
			layer = undefined
			path = undefined
			status = undefined
			c = undefined
			if slashAdded
				wiz.log.err 'slashAdded!'
				req.url = req.url.substr(1)
				slashAdded = false
			req.url = removed + req.url
			req.originalUrl = req.originalUrl or req.url
			removed = ""

			# next callback
			layer = stack[index++]

			# all done
			if not layer or res.headerSent

				# delegate to parent
				return out(err) if out

				# unhandled error
				if err

					# default to 500
					res.statusCode = 500 if res.statusCode < 400
					#wiz.log.debug "default #{res.statusCode}"

					# respect err.status
					res.statusCode = err.status if err.status

					# print error
					msg = if true then http.STATUS_CODES[res.statusCode] else err.stack or err.toString()
					console.error err.stack or err.toString()

					return req.socket.destroy() if res.headerSent
					res.setHeader "Content-Type", "text/plain"
					res.setHeader "Content-Length", Buffer.byteLength(msg)
					return res.end() if "HEAD" is req.method
					res.end msg
				else
					#wiz.log.debug "default 404"
					res.statusCode = 404
					res.setHeader "Content-Type", "text/plain"
					return res.end() if "HEAD" is req.method
					res.end "Cannot " + req.method + " " + wiz.framework.frontend.util.escape(req.originalUrl)
				return
			try
				path = wiz.framework.frontend.util.parseUrl(req).pathname
				path = "/" if`undefined`is path

				# skip this layer if the route doesn't match.
				return next(err) unless 0 is path.toLowerCase().indexOf(layer.route.toLowerCase())
				c = path[layer.route.length]
				return next(err) if c and "/" isnt c and "." isnt c

				# Call the layer handler
				# Trim off the part of the url that matches the route
				removed = layer.route
				req.url = req.url.substr(removed.length)

				# Ensure leading slash
				if not fqdn and "/" isnt req.url[0]
					req.url = "/" + req.url
					slashAdded = true
				#wiz.log.debug layer.handle.name or "anonymous"
				arity = layer.handle.length
				if err
					if arity is 4
						layer.handle err, req, res, next
					else
						next err
				else if arity < 4
					layer.handle req, res, next
				else
					next()
			catch e
				next e

		next()

	listen: (port) =>
		@http.listen @config.httpPort, @config.httpHost
		wiz.log.warning "HTTP listening on [#{@config.httpHost}]:#{@config.httpPort}"

# vim: foldmethod=marker wrap
