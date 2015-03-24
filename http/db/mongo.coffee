# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../../database/mongo/driver'
require '../../crypto/hash'

wiz.package 'wiz.framework.http.database.mongo'

class wiz.framework.http.database.mongo.driver extends wiz.framework.database.mongo.driver
	client: null

	constructor: (@server, @parent, @config, @serverOptions, @dbOptions) -> #{{{
		super()
	#}}}
	init: () => #{{{
		super (err, @client) =>
			if not @client or err
				wiz.log.err "failed connecting to database #{@config.database} #{err}"
				return null
			wiz.log.debug "connected to database #{@config.database}"
	#}}}
	collection: (res, collectionName, cb) => #{{{
		super @client, collectionName, true, (err, collection) =>
			# only call cb if we have collection
			if err or not collection
				wiz.log.err "unable to retrieve collection #{@config.database}.#{collectionName} #{err}"
				res.send 500
				return null
			cb collection
	#}}}

class wiz.framework.http.database.mongo.base

	debug: false
	upsert: true
	collectionName: ''
	docKey: ''

	constructor: (@server, @parent, @mongo) -> #{{{
		wiz.assert(@parent, "invalid @parent: #{@parent}")
		wiz.assert(@mongo, "invalid @mongo: #{@mongo}")
	#}}}
	init: () => #{{{
	#}}}
	getDocKey: (id) => #{{{
		query = {}
		query[@docKey] = id
		return query
	#}}}
	fields: (req) => #{{{ allow child class to override
		return {}
	#}}}
	query: (req) => #{{{ allow child class to override
		return {}
	#}}}
	count: (req, res, query, fields, cb) => #{{{
		debugstr = "#{@collectionName}.count(#{JSON.stringify(query)}, #{JSON.stringify(fields)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			collection.find(query, fields).count (err, count) =>
				if err
					wiz.log.err "COUNT FAILED: #{debugstr} -> #{err}"
					return cb null if cb
					return res.send 500

				wiz.log.info "COUNT OK: #{debugstr}"
				return cb count if cb
				return res.send 200
	#}}}
	find: (req, res, query, fields, opts = {}, cb) => #{{{
		debugstr = "#{@collectionName}.find(#{JSON.stringify(query)}, #{JSON.stringify(fields)}, #{JSON.stringify(opts)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			found = collection.find(query, fields, opts)
			found.toArray (err, results) =>
				if err
					wiz.log.err "FIND FAILED: #{debugstr} -> #{err}"
					return cb null if cb
					return res.send 500

				wiz.log.info "FIND OK: #{debugstr}" if @debug
				return cb results if cb
				return res.send 200
	#}}}
	findOne: (req, res, query, fields, cb) => #{{{
		debugstr = "#{@collectionName}.findOne(#{JSON.stringify(query)}, #{JSON.stringify(fields)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			collection.findOne query, fields, (err, result) =>
				if err
					wiz.log.err "FINDONE FAILED: #{debugstr} -> #{err}"
					return cb req, res, null if cb
					return res.send 500

				wiz.log.info "FINDONE OK: #{debugstr}" if @debug
				wiz.log.debug "FINDONE RESULT: #{JSON.stringify(result)}" if @debug
				return cb req, res, result if cb
				return res.send 200
	#}}}
	insert: (req, res, query, cb) => #{{{
		debugstr = "#{@collectionName}.insert(#{JSON.stringify(query)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			collection.insert query.toJSON(), (err, query) =>
				if err
					wiz.log.err "INSERT FAILED: #{debugstr} -> #{err}"
					return cb null if cb
					return res.send 500

				wiz.log.info "INSERT OK: #{debugstr}"
				return cb query if cb
				return res.send 200
	#}}}
	updateCustom: (req, res, query, update, options, cb) => #{{{
		debugstr = "#{@collectionName}.update(#{JSON.stringify(query)}, #{JSON.stringify(update)}, #{JSON.stringify(options)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			collection.update query, update, options, (err, result) =>
				if err
					wiz.log.err "UPDATE FAILED: #{debugstr} -> #{err}"
					return cb null if cb
					return res.send 500

				wiz.log.info "UPDATE OK: #{debugstr}"
				return cb result if cb
				return res.send 200
	#}}}
	listResponse: (req, res, data, recordCount) => #{{{
		data = [] if not data or data not instanceof Array
		recordCount ?= data.length
		res.setHeader 'Content-Type', 'application/json'
		res.send 200,
			sEcho : req.query?.sEcho
			iTotalRecords : recordCount
			iTotalDisplayRecords : recordCount
			aaData : data
	#}}}
	drop: (req, res, cb) => #{{{ default drop ajax handler
		return res.send 400 if not req.body.recordsToDelete or typeof req.body.recordsToDelete isnt 'object' # only proceed if object

		recordsToDelete = []
		if req.body.recordsToDelete and req.body.recordsToDelete.length > 0
			for id, i in req.body.recordsToDelete
				recordsToDelete[i] = @mongo.oid(id)
		@dropMany req, res, recordsToDelete, cb
	#}}}
	dropMany: (req, res, recordsToDelete, cb) => #{{{ send mongo query to drop a given array of mongo oid objects
		dropQuery =
			_id : { $in : recordsToDelete }

		@parent.parent.mongo.collection res, @collectionName, (collection) =>
			debugstr = "#{@collectionName}.remove(#{JSON.stringify(dropQuery)})"
			wiz.log.debug debugstr if @debug
			collection.remove dropQuery, (err, count) =>
				if err
					wiz.log.err "DROP FAILED FOR #{recordsToDelete}: #{err}"
					res.send 500 if res
					cb false if cb
					return

				wiz.log.info "DROP OK: #{debugstr}"
				res.send 200 if res
				cb true if cb
				return
	#}}}

class wiz.framework.http.database.mongo.baseArray extends wiz.framework.http.database.mongo.base

	arrayKey: ''
	elementKey: 'id'

	getDocKeyWithElementID: (queryID, elementID) => #{{{
		query = @getDocKey(queryID)
		query[@arrayKey] = {}
		query[@arrayKey].$elemMatch = {}
		query[@arrayKey].$elemMatch[@elementKey] = elementID
		return query
	#}}}
	getArrayKey: (keys = [ @arrayKey ]) => #{{{
		fields = {}
		fields[key] = 1 for key in keys
		return fields
	#}}}
	getUpdateSetObj: (req, objsToSet) => #{{{
		update = {}
		update['$set'] = {}
		for k, v of objsToSet
			setKey = @arrayKey + '.$.' + k
			update['$set'][setKey] = v
			update['$set'][setKey].updated = wiz.framework.util.datetime.unixFullTS()
		return update
	#}}}
	getUpdatePushArray: (req, objToPush, pushKey) => #{{{
		pushKey ?= @arrayKey
		toPush = {}
		toPush[pushKey] = objToPush.toDB(req)
		update =
			'$set' : { updated: wiz.framework.util.datetime.unixFullTS() }
			'$push': toPush
		return update
	#}}}
	getUpdatePullArray: (req, objToPull, pullKey) => #{{{
		pullKey ?= @arrayKey
		toPull = {}
		toPull[pullKey] = {}
		toPull[pullKey][@elementKey] = objToPull
		toPull[pullKey].immutable = false # if not-admin
		update =
			'$set' : { updated: wiz.framework.util.datetime.unixFullTS() }
			'$pull': toPull
		return update
	#}}}
	getUpdateOptions: () => #{{{
		options =
			upsert: @upsert
		return options
	#}}}
	findElementByID: (req, res, queryID, elementID, cb) => #{{{
		return cb(null) if not queryID or not elementID
		@findElementByCustom(req, res, @getDocKeyWithElementID(queryID, elementID), @getArrayKey(), @elementKey, elementID, cb)
	#}}}
	findElementByCustom: (req, res, query, fields, elementKey, elementID, cb) => #{{{
		@findOne req, res, query, fields, (req, res, result) =>
			if result and result[@arrayKey]
				for ri of result[@arrayKey] when r = result[@arrayKey][ri]
					if r[elementKey] == elementID
						return cb(r)
			return cb(null)
	#}}}
	insertOne: (req, res, queryID, objToInsert) => #{{{
		query = @getDocKey queryID
		update = @getUpdatePushArray req, objToInsert
		options = @getUpdateOptions()
		@updateCustom(req, res, query, update, options)
	#}}}
	modifyOne: (req, res, queryID, objToModify) => #{{{
		res.send 501
	#}}}
	dropMany: (req, res, queryID, elementID, objsToDelete, pullKey = null) => #{{{
		@mongo.collection res, @collectionName, (collection) =>
			# count records to drop
			pending = 0
			for t, toDelete of objsToDelete
				pending += 1

			# for each type in object, make query with given array
			for t, toDelete of objsToDelete
				# TODO: check permissions!!
				if elementID
					query = @getDocKeyWithElementID(queryID, elementID)
				else
					query = @getDocKey(queryID)
				update = @getUpdatePullArray(req, toDelete, pullKey)
				options = @getUpdateOptions()
				@updateCustom req, res, query, update, options, (result) =>
					res.send 200 if (pending -= 1) == 0
	#}}}

# vim: foldmethod=marker wrap
