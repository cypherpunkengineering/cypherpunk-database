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

# database package
wizpackage 'wizdb'

# native mongodb driver
mongodb = require 'mongodb'

class wizdb.mongo

	mongoConfig : {}
	mongoServerOptions : {}
	mongoDbOptions : {}

	mongoInit : (mongoConfig, mongoServerOptions, mongoDbOptions, cb) =>

		this.mongoConfig = mongoConfig
		this.mongoServerOptions = mongoServerOptions
		this.mongoDbOptions = mongoDbOptions

		this.mongoConnectDB (err, client) =>
			cb err, client

	# connect and auth to mongo database
	mongoConnectDB : (cb) =>
		unless mongoServer = new mongodb.Server this.mongoConfig.hostname, 27017, this.mongoServerOptions
			return cb 'mongodb.Server() failed'

		unless mongoDB = new mongodb.Db this.mongoConfig.database, mongoServer, this.mongoDbOptions
			return cb 'mongodb.Db() failed'

		mongoDB.open (err, client) =>
			if err or not client
				return cb 'mongoDB.open() failed: ' + err

			client.authenticate this.mongoConfig.username, this.mongoConfig.password, (err, auth) =>
				if err or not auth
					return cb 'client.authenticate() failed: ' + err

				cb null, client

	# retreive a mongo collection from given database handle
	mongoGetCollection : (client, collectionName, stayOpen, cb) =>
		# check if non-null client
		unless client
			return cb 'no database connection!'

		# retreive the collection
		unless collection = new mongodb.Collection(client, collectionName)
			return cb 'mongodb.Collection returned null'

		# call the cb
		cb null, collection

		# close the db connection unless told not to
		client.close() unless stayOpen

# vim: foldmethod=marker wrap
