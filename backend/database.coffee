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
require '../database/mongo/driver'

wiz.package 'wiz.framework.backend'

# mongo class
class wiz.framework.backend.mongo extends wiz.framework.database.mongo.driver

	verbose : false

	constructor : (@parent, @config, @serverOptions, @dbOptions) ->
		super()
		@init()

	init : () =>
		# just test database connection
		super (err, client) =>
			if client
				if @verbose then wiz.log.debug 'initial database connection OK'
				@disconnect(client)

	connect : (cb) =>
		if @verbose then wiz.log.debug "connecting to mongo database #{@config.database}"
		super (err, client) =>
			# call cb even if err
			if not client or err
				wiz.log.err "unable to connect to mongo database #{@config.database} #{err}"
			cb err, client

	disconnect : (client) =>
		if @verbose then wiz.log.debug "disconnecting from mongo database #{@config.database}"
		super (client)

	collection : (client, collectionName, stayOpen, cb) =>
		super client, collectionName, stayOpen, (err, collection) =>
			# only call cb if we have collection
			if not collection or err
				wiz.log.err "unable to retrieve collection #{@config.database}.#{collectionName} #{err}"
				return
			cb err, collection

	# for storing javascript methods in database
	saveJS : (methodsToSave) =>
		wiz.log.debug 'preparing to save JS to database'
		@connect (err, client) =>
			@collection client, 'system.js', false, (err, systemJS) =>
				for methodName, methodCode of methodsToSave
					wiz.log.debug "saving #{methodName} to database"
					# save db methods as stored JS
					systemJS.save
						'_id' : methodName
						'value' : @code(methodCode)

# vim: foldmethod=marker wrap
