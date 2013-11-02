# copyright 2013 wiz technologies inc.

require '../..'

mongodb = require 'mongodb'
BSON = mongodb.BSONPure

wiz.package 'wiz.framework.database.mongo'

class wiz.framework.database.mongo.driver

	config: {}
	serverOptions: {}
	dbOptions: {}

	init: (cb) =>
		@connect (err, client) =>
			cb err, client

	# connect and auth to mongo database
	connect: (cb) =>
		unless mongoServer = new mongodb.Server @config.hostname, 27017, @serverOptions
			return cb "mongodb.Server(#{@config.hostname}) failed: #{err}"

		unless mongoDB = new mongodb.Db @config.database, mongoServer, @dbOptions
			return cb "mongodb.Db(#{@config.hostname}) failed: #{err}"

		mongoDB.open (err, client) =>
			if err or not client
				return cb "mongoDB.open(#{@config.hostname}) failed: #{err}"

			if @config and not @config.username
				return cb null, client

			client.authenticate @config.username, @config.password, (err, auth) =>
				if err or not auth
					return cb "client.authenticate(#{@config.username}, #{@config.hostname}) failed: #{err}"

				cb null, client

	# retreive a mongo collection from given database handle
	collection: (client, collectionName, stayOpen, cb) =>
		# check if non-null client
		unless client
			return cb 'no database connection!'

		# retreive the collection
		unless collection = new mongodb.Collection(client, collectionName)
			return cb "mongodb.Collection(#{@collectionName}) returned null"

		# call the cb
		cb null, collection

		# close the db connection unless told not to
		if not stayOpen
			@disconnect(client)

	disconnect: (client) =>
		client.close()

	code: (func) =>
		return new mongodb.Code(func)

	dateFromID: (id) =>
		try
			ts = id.toString().substring(0,8)
			date = new Date(parseInt(ts, 16) * 1000)
		catch e
			return new Date(-1)
		return date

	oid: (id) =>
		return new BSON.ObjectID(id)

# vim: foldmethod=marker wrap
