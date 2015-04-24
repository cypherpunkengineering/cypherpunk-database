# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'

mongodb = require 'mongodb'

wiz.package 'wiz.framework.database.mongo'

class wiz.framework.database.mongo.driver

	debug: false
	config: {}
	serverOptions: {}
	dbOptions: {}
	port: 27017
	client: null

	init: (cb) => #{{{ init driver instance
		@connect (err) =>
			# err = "mongo driver init failed: #{err}" if err
			cb(err) if cb
	#}}}
	connect: (cb) => #{{{ connect and auth to mongo database
		unless mongoServer = new mongodb.Server @config.hostname, @port, @serverOptions
			return cb "mongodb.Server(#{@config.hostname}) failed: #{err}"

		unless mongoDB = new mongodb.Db @config.database, mongoServer, @dbOptions
			return cb "mongodb.Db(#{@config.hostname}) failed: #{err}"

		mongoDB.open (err, @client) =>
			if err or not @client
				return cb "mongoDB.open(#{@config.hostname}) failed: #{err}"

			# if authentication credentials specified, try calling authenticate()
			if @config?.username
				@client.authenticate @config.username, @config.password, (err, auth) =>
					if err or not auth
						return cb "client.authenticate(#{@config.username}, #{@config.hostname}) failed: #{err}"

			# no error
			return cb(null)
	#}}}
	collection: (collectionName, cb) => #{{{ retreive a mongo collection
		# check if non-null client
		return cb 'no database connection!' unless @client

		# retreive the collection
		if not collection = new mongodb.Collection(@client, collectionName)
			return cb "mongodb.Collection(#{@collectionName}) returned null"

		# no error, return the collection
		cb null, collection
	#}}}
	disconnect: () => #{{{ no need to call if auto_connect is enabled
		@client.close()
	#}}}
	code: (func) => #{{{
		return new mongodb.Code(func)
	#}}}

	saveSystemJS: (saveSystemJSmapping, cb = null) => #{{{ for storing javascript methods in database
		wiz.log.debug 'preparing to save JS to database' if @debug
		@collection @_systemJScollectionName, (err, @_systemJScollection) =>
			if err or not @_systemJScollection
				wiz.log.err "unable to get SystemJS collection #{@_systemJScollectionName}"
				cb(err) if cb
				return

			# save systemJS objects to array
			for name, code of saveSystemJSmapping
				@_saveSystemJSlist.push
					name: name
					code: code

			# start callback based loop to save systemJS code one at time
			@_saveSystemJScb = cb
			@_saveSystemJSnext()
	#}}}
	#{{{ saveSystemJS private code
	_systemJScollectionName: 'system.js'
	_systemJScollection: null
	_saveSystemJSlist: []
	_saveSystemJScb: null
	_saveSystemJSone: (systemJSobj) => #{{{ store a single JS method in DB
		wiz.log.debug "saving #{systemJSobj.name} to database" if @debug

		# save db methods as stored JS
		objToSave =
			_id: systemJSobj.name
			value: @code(systemJSobj.code)
		opts =
			writeConcern:
				w: 'majority'
				wtimeout: 5000

		@_systemJScollection.save(objToSave, opts, @_saveSystemJSnext)
	#}}}
	_saveSystemJSnext: (err = null) => #{{{ cb for _saveSystemJSone
		wiz.log.err "error saving #{methodName} to system.js database: #{err}" if @err
		if @_saveSystemJSlist.length > 0
			@_saveSystemJSone @_saveSystemJSlist.pop()
		else
			wiz.log.debug "done saving systemJS code to database" if @debug
			@_saveSystemJScb() if @_saveSystemJScb
	#}}}
	#}}}

	dateFromID: (id) => #{{{ extract date from mongo document id
		try
			ts = id.toString().substring(0,8)
			date = new Date(parseInt(ts, 16) * 1000)
		catch e
			return new Date(-1)
		return date
	#}}}
	oid: (id) => #{{{ get oid of a BSON object
		BSON = mongodb.BSONPure
		return new BSON.ObjectID(id)
	#}}}

	dayFromDate: (date) -> #{{{ date like this: 2012.04.01
		key = date.getFullYear()
		key += '.' + ('0' + (date.getMonth() + 1)).slice(-2)
		key += '.' + ('0' + date.getDate()).slice(-2)
		return key
	#}}}
	dayhourFromDate: (date) -> #{{{ date like this: 2012.04.01.09
		# key = dayFromDate(date)
		key = date.getFullYear()
		key += '.' + ('0' + (date.getMonth() + 1)).slice(-2)
		key += '.' + ('0' + date.getDate()).slice(-2)
		key += '.' + ('0' + date.getHours()).slice(-2)
		return key
	#}}}

# vim: foldmethod=marker wrap
