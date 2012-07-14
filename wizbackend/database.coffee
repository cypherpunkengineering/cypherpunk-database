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

# wizbackend package
wizpackage 'wizbackend'

# mysql class
class wizbackend.mysql extends wizdb.mysql
# mongo class
class wizbackend.mongo extends wizdb.mongo

	verbose : false

	constructor : (@parent, @config, @serverOptions, @dbOptions) ->
		super()
		@init()

	init : () =>
		# just test database connection
		super (err, client) =>
			if client
				if @verbose then wizlog.debug @constructor.name, 'initial database connection OK'
				@disconnect(client)

	connect : (cb) =>
		if @verbose then wizlog.debug @constructor.name, "connecting to mongo database #{@config.database}"
		super (err, client) =>
			# call cb even if err
			if not client or err
				wizlog.err @constructor.name, "unable to connect to mongo database #{@config.database} #{err}"
			cb err, client

	disconnect : (client) =>
		if @verbose then wizlog.debug @constructor.name, "disconnecting from mongo database #{@config.database}"
		super (client)

	collection : (client, collectionName, stayOpen, cb) =>
		super client, collectionName, stayOpen, (err, collection) =>
			# only call cb if we have collection
			if not collection or err
				wizlog.err @constructor.name, "unable to retrieve collection #{@config.database}.#{collectionName} #{err}"
				return
			cb err, collection

	# date like this: 2012.04.01
	dayFromDate : (date) ->
		key = date.getFullYear()
		key += '.' + ('0' + date.getMonth()).slice(-2)
		key += '.' + ('0' + date.getDate()).slice(-2)
		return key

	# date like this: 2012.04.01.09
	dayhourFromDate : (date) ->
		# key = dayFromDate(date)
		key = date.getFullYear()
		key += '.' + ('0' + date.getMonth()).slice(-2)
		key += '.' + ('0' + date.getDate()).slice(-2)
		key += '.' + ('0' + date.getHours()).slice(-2)
		return key

	# for storing javascript methods in database
	saveJS : (methodsToSave) =>
		wizlog.debug @constructor.name, 'preparing to save JS to database'
		@connect (err, client) =>
			@collection client, 'system.js', false, (err, systemJS) =>
				for methodName, methodCode of methodsToSave
					wizlog.debug @constructor.name, "saving #{methodName} to database"
					# save db methods as stored JS
					systemJS.save
						'_id' : methodName
						'value' : @code(methodCode)

# vim: foldmethod=marker wrap
