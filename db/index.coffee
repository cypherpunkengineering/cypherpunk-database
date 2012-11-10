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

wiz.package 'wiz.framework.db'

# native mysql driver
MySQL = require 'mysql'

class wiz.framework.db.mysql
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

# native mongodb driver
mongodb = require 'mongodb'
BSON = mongodb.BSONPure

class wiz.framework.db.mongo

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

			if @server and @server.config and @server.config.mongoDoAuth is false
				return cb null, client

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
		if not stayOpen
			@disconnect(client)

	disconnect : (client) =>
		client.close()

	code : (func) =>
		return new mongodb.Code(func)

	dateFromID : (id) =>
		try
			ts = id.toString().substring(0,8)
			date = new Date(parseInt(ts, 16) * 1000)
		catch e
			return new Date(-1)
		return date

	oid: (id) =>
		return new BSON.ObjectID(id)

# native riak driver
riakJS = require '../_deps/riak-js'

class wiz.framework.db.riak
	client: null
	config:
		host: 'localhost'
		port: 8098

	constructor: (@config) ->

	init: () =>
		@client = riakJS.getClient
			host: @config.host
			port: @config.port

# vim: foldmethod=marker wrap
