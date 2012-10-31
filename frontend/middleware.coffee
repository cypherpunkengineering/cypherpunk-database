# wiz-framework: J's HTML5/NodeJS web application framework
#
# Copyright 2012 J. Maurice <j@wiz.biz>
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of version 3 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

require '..'
require '../util/strval'
require '../util/datetime'

wiz.package 'wiz.framework.frontend'

express = require 'express'

# created from wiz.framework.frontend.server constructor
class wiz.framework.frontend.middleware

	# allow access from these hosts
	accessList : [
		'127.0.0.1'
		'::1'
	]

	# display middleware errors to these hosts
	developerlist : [
		'127.0.0.1'
		'::1'
	]

	# log format passed to express.logger and logged to wiz.log()
	logFormat : '[:remote-addr] ":method :url HTTP/:http-version" :status :res[content-length] ":referrer" ":user-agent'

	# for wiz.log() use
	logStream:
		write: (str) ->
			wiz.log.debug str

	# useful error strings
	errorstr :
		hosthdr : 'missing host header'
		403 : 'access denied'
		500 : 'server error'

	constructor: (@parent) ->

	checkAuth : (req, res, next) =>
		if req and req.session and req.session.wiz and req.session.wiz.auth
			return next() if next
			return true
		if next
			wiz.log.info "unauthorized request"
			@parent.redirect req, res, null, '/login?for=' + escape(req.url), 307
		return false

	checkAuthAjax : (req, res, next) =>
		# if auth, proceed
		if req and req.session and req.session.wiz and req.session.wiz.auth
			return next() if next
			return true
		# otherwise send 401
		if next
			wiz.log.info "unauthorized ajax request"
			res.send 401
		return false

	checkDeveloper : (req, res) =>
		ip = @getIP req
		if @developerList.indexOf(ip) != -1 # paranthesis needed
			return true
		return false

	getIP : (req) =>
		return wiz.framework.util.strval.inet6_prefix_trim req.connection.remoteAddress

	# filter requests to trusted ips only
	checkIP : (req, res, next) =>
		ip = @getIP req
		if @accessList.indexOf(ip) is -1 # paranthesis needed
			wiz.log.info "#{@errorstr[403]}"
			res.send @errorstr[403], 200
			return false
		return next() if next
		return true

	checkHostHeader : (req, res, next) =>
		# validate host header as valid host, strip port off if necessary
		return @parent.error 'missing host header', req, res, 400 unless req.headers.host
		return next() if next
		return true

	parseHostHeader : (req, res, next) =>
		if (
			not hostar = req.headers.host.split ':'
		) or (
			not host = hostar[0]
		) or (
			not wiz.framework.util.strval.validate 'fqdnDot', host
		)

			return @parent.error 'invalid host header', req, res, 404

		if req and req.session and req.session.wiz
			req.session.wiz.host = host

		return next() if next
		return true

	# remove x-powered-by header from express lib
	hideHeader : (req, res, next) =>
		res.removeHeader 'X-Powered-By'
		res.setHeader 'X-Powered-By', 'wiz'
		return next() if next
		return true

	# absolute minimum middleware
	base : () =>
		return [
			# remove express header
			@hideHeader

			# maximum request size
			express.limit @parent.config.requestLimit

			# check if host header is missing
			@checkHostHeader

			# check IP before handling errors
			# @checkIP

			# log requests
			express.logger

				# use custom format
				format: @logFormat

				# log to wiz.log()
				stream: @logStream

			express.compress()

			express.staticCache()
		]

	# normal use for requests needing session data
	baseSession : () =>
		return [
			# start with base
			@base()

			# parse request params
			express.bodyParser()

			# parse cookies
			express.cookieParser()

			# setup session handler
			express.session

				# session id secret
				secret: @parent.config.sessionSecret

				# use RedisStore from parent object
				store: @parent.sessionRedisStore

				# important! set secure flag on cookies!
				cookie:
					secure: true

			@parent.sessionCreate

			@parseHostHeader

			@parent.sessionInit
		]

	# baseSession with required authentication
	baseSessionAuth : () =>
		return [
			@baseSession()
			@checkAuth
		]

	# baseSessionAuth for jQuery.datatable ajax requests
	baseSessionAuthAjax : () =>
		return [
			@baseSession()
			@checkAuthAjax
		]


# vim: foldmethod=marker wrap
