# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'

mongoDB = require('mongodb')
mongoClient = require('mongodb').MongoClient

wiz.package 'wiz.framework.database.mongo'

class wiz.framework.database.mongo.driver

	debug: false
	mongoURI: null
	mongoOptions:
		promiseLibrary: require('bluebird')
		socketOptions:
			keepAlive: 1
			connectTimeoutMS: 30000
		reconnectTries: 10
		reconnectInterval: 500
	db: null

	init: (cb) => #{{{ init driver instance
		@disconnect()
		@connect (err) =>
			# err = "mongo driver init failed: #{err}" if err
			cb(err) if cb
	#}}}
	connect: (cb) => #{{{ connect and auth to mongo database
		mongoClient.connect @mongoURI, @mongoOptions, (err, @db) =>
			if err or not @db
				return cb "mongoClient.connect(#{@mongoURI}) failed: #{err}"

			# no error
			return cb(null)
	#}}}
	collection: (collectionName, cb) => #{{{ retreive a mongo collection
		# check if non-null db
		return cb 'No database connection!' unless @db

		# retreive the collection
		@db.collection collectionName, (err, collection) =>
			if err
				# try re-initializing and hope it reconnects
				@onError(err)
				return cb("db.collection(#{collectionName}) returned null: #{err}")

			# no error, return the collection
			cb null, collection
	#}}}
	disconnect: () => #{{{ no need to call if auto_connect is enabled
		@db.close() if @db
	#}}}
	code: (func) => #{{{
		return new mongoDB.Code(func)
	#}}}

	onError: (err) => #{{{ critical error
		# try reset stuff
		wiz.log.crit "Re-initializing mongo due to critical error: #{err}"
		@init()
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
#		BSON = mongodb.BSONPure
#		return new BSON.ObjectID(id)
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
	dayhourToDate: (ts) => #{{{ date like this: 2012.04.01.09
		s = ts.split '.'
		# month is zero-index
		return new Date(s[0], s[1] - 1, s[2], s[3])
	#}}}

# vim: foldmethod=marker wrap
