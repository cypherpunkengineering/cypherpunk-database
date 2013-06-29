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
require '../database/mysql'
require '../database/mongo'
require '../database/s3'

wiz.package 'wiz.framework.frontend.database'

# node frameworks
connect = require 'connect'

class wiz.framework.frontend.mysql extends wiz.framework.database.mysql
	constructor : (@server, @parent, @config) ->
		super(@config)

class wiz.framework.frontend.mongo extends wiz.framework.database.mongo
	client : null

	constructor : (@server, @parent, @config, @serverOptions, @dbOptions) ->
		super()
		@init()

	init: () =>
		super (err, @client) =>
			if not client or err
				wiz.log.err "failed connecting to database #{@config.database} #{err}"
				return null
			wiz.log.debug "connected to database #{@config.database}"

	collection : (res, collectionName, cb) =>
		super @client, collectionName, true, (err, collection) =>
			# only call cb if we have collection
			if err or not collection
				wiz.log.err "unable to retrieve collection #{@config.database}.#{collectionName} #{err}"
				res.send 500
				return null
			cb collection

class wiz.framework.frontend.database.s3 extends wiz.framework.database.s3

	createNewBucket: (req, res, bucket) =>
		super bucket, (out) =>
			return res.send out.statusCode if out
			wiz.log.error "S3 request failed"
			return res.send 500

	issueCredentials: (req, res, name, email, userKey, cb) =>
		super name, email, userKey, (out) =>
			if not out or not out.key_id or not out.key_secret
				wiz.log.error "S3 request failed"
				return res.send 500
			cb out

# vim: foldmethod=marker wrap
