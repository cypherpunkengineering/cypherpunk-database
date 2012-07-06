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

# wiz-framework
require '..'
require '../wizdb'

# wizfrontend package
wizpackage 'wizfrontend'

# node frameworks
connect = require 'connect'

# database drivers
MySQL = require 'mysql'

class wizfrontend.mysql
	client : null
	config :
		host : ''
		user : ''
		password : ''

	constructor : (@config) ->
		@client = new MySQL.Client()
		@client.host = @config.hostname
		@client.user = @config.username
		@client.password = @config.password

class wizfrontend.mongo extends wizdb.mongo
	client : null

	constructor : (@config, @serverOptions, @dbOptions) ->
		super()
		@init()

	init: () =>
		super (err, @client) =>
			if not client and not err
				err = "failed connecting to database #{@config.database}"
			if err
				wizlog.err @constructor.name, 'init: ' + err
				return null
			wizlog.debug @constructor.name, "connected to database #{@config.database}"

	collection : (res, collectionName, cb) =>
		super @client, collectionName, true, (err, collection) =>
			if err
				wizlog.err @constructor.name, "unable to retrieve collection #{@config.database}.#{collectionName}: #{err}"
				res.send err, 500
				return null
			cb collection

# vim: foldmethod=marker wrap
