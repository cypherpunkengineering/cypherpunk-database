# copyright 2013 wiz technologies inc.

require '..'
require '../database/mysql'
require '../database/mongo'
require '../database/s3'

wiz.package 'wiz.framework.http.database'

# node frameworks
connect = require 'connect'

class wiz.framework.http.mysql extends wiz.framework.database.mysql
	constructor : (@server, @parent, @config) ->

class wiz.framework.http.mongo extends wiz.framework.database.mongo
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

class wiz.framework.http.database.s3 extends wiz.framework.database.s3

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
