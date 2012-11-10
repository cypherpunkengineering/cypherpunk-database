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
require '../db'

wiz.package 'wiz.framework.frontend'

# node frameworks
connect = require 'connect'

class wiz.framework.frontend.mysql extends wiz.framework.db.mysql
	constructor : (@server, @parent, @config) ->

class wiz.framework.frontend.riak extends wiz.framework.db.riak

class wiz.framework.frontend.mongo extends wiz.framework.db.mongo
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

# vim: foldmethod=marker wrap
