# copyright 2013 wiz technologies inc.

require '..'
require '../database/mysql'
require '../database/mongo'

wiz.package 'wiz.framework.http.database'

class wiz.framework.http.mysql extends wiz.framework.database.mysql
	constructor : (@server, @parent, @config) ->

class wiz.framework.http.mongo extends wiz.framework.database.mongo
	client : null

	constructor : (@server, @parent, @config, @serverOptions, @dbOptions) ->
		super()

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

# vim: foldmethod=marker wrap
