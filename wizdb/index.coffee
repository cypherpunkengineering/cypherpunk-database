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

	config : {}
	serverOptions : {}
	dbOptions : {}

	init : (cb) =>
		@connect (err, client) =>
			cb err, client

	# connect and auth to mongo database
	connect : (cb) =>
		unless mongoServer = new mongodb.Server @config.hostname, 27017, @serverOptions
			return cb "mongodb.Server(#{@config.hostname}) failed: #{err}"

		unless mongoDB = new mongodb.Db @config.database, mongoServer, @dbOptions
			return cb "mongodb.Db(#{@config.hostname}) failed: #{err}"

		mongoDB.open (err, client) =>
			if err or not client
				return cb "mongoDB.open(#{@config.hostname}) failed: #{err}"

			client.authenticate @config.username, @config.password, (err, auth) =>
				if err or not auth
					return cb "client.authenticate(#{@config.username}, #{@config.hostname}) failed: #{err}"

				cb null, client

	# retreive a mongo collection from given database handle
	collection : (client, collectionName, stayOpen, cb) =>
		# check if non-null client
		unless client
			return cb 'no database connection!'

		# retreive the collection
		unless collection = new mongodb.Collection(client, collectionName)
			return cb "mongodb.Collection(#{@collectionName}) returned null"

		# call the cb
		cb null, collection

		# close the db connection unless told not to
		client.close() unless stayOpen

	dateFromID : (id) =>
		try
			ts = id.toString().substring(0,8)
			date = new Date(parseInt(ts, 16) * 1000)
		catch e
			return new Date(-1)
		return date

# vim: foldmethod=marker wrap
