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
require '../wizutil/wizstring'
require '../wizutil/datetime'

wizpackage 'wiz.frontend'

express = require 'express'

# created from wiz.frontend.server constructor
class wiz.frontend.middleware

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

	# log format passed to express.logger and logged to wizlog()
	logFormat : '[:remote-addr] ":method :url HTTP/:http-version" :status :res[content-length] ":referrer" ":user-agent'

	# for wizlog() use
	logStream:
		write: (str) ->
			wizlog.debug 'weblog', str

	# useful error strings
	errorstr :
		hosthdr : 'missing host header'
		403 : 'access denied'
		500 : 'server error'

	constructor: (@parent) ->

	checkAuth : (req, res, next) =>
		if req and req.session and req.session.wizfrontendAuth
			return next() if next
			return true
		if next
			wizlog.debug @constructor.name, "unauthorized redirect"
			@parent.redirect req, res, null, '/'
		return false

	checkAuthDatatable : (req, res, next) =>
		# if auth, proceed
		if req.session.wizfrontendAuth
			return next() if next
			return true
		# otherwise send null response
		res.send
			sEcho : req.query.sEcho
			iTotalRecords : 0
			iTotalDisplayRecords : 0
			aaData : []
		return false

	checkDeveloper : (req, res) =>
		ip = @getIP req
		if @developerList.indexOf(ip) != -1 # paranthesis needed
			return true
		return false

	getIP : (req) =>
		return wiz.util.strval.inet6_prefix_trim req.connection.remoteAddress

	# filter requests to trusted ips only
	checkIP : (req, res, next) =>
		ip = @getIP req
		if @accessList.indexOf(ip) is -1 # paranthesis needed
			wizlog.info @constructor.name, "#{@errorstr[403]}"
			res.send @errorstr[403], 200
			return false
		return next() if next
		return true

	checkHostHeader : (req, res, next) =>
		unless 'host' of req.headers
			wizlog.info @constructor.name, "#{@errorstr.hosthdr}"
			res.send @errorstr.hosthdr, 400
			return false
		return next() if next
		return true

	# remove x-powered-by header from express lib
	hideHeader : (req, res, next) =>
		res.removeHeader "X-Powered-By"
		return next() if next
		return true

	# initialize all session variables
	sessionInit: (req, res, next) =>
		req.session.wizfrontendAuth ?= false
		req.session.wizfrontendMask ?= wiz.util.bitmask.set(0, @parent.powerMask.public)
		req.session.wizfrontendLevel ?= @parent.powerLevel.stranger
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

				# log to wizlog()
				stream: @logStream
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

			@sessionInit
		]

	# baseSession with required authentication
	baseSessionAuth : () =>
		return [
			@baseSession()
			@checkAuth
		]

	# baseSessionAuth for jQuery.datatable ajax requests
	baseSessionAuthDatatable : () =>
		return [
			@baseSession()
			@checkAuthDatatable
		]


# vim: foldmethod=marker wrap
