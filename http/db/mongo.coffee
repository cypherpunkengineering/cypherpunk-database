# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../../database/mongo/driver'
require '../../crypto/hash'

wiz.package 'wiz.framework.http.database.mongo'

class wiz.framework.http.database.mongo.driver extends wiz.framework.database.mongo.driver
	constructor: (@server, @parent, @config, @serverOptions, @dbOptions) -> #{{{
		super()
	#}}}
	init: () => #{{{
		super (err) =>
			if not @client or err
				wiz.log.err "failed connecting to database #{@config.database} #{err}"
				return null
			wiz.log.debug "connected to database #{@config.database}"
	#}}}
	collection: (res, collectionName, cb) => #{{{
		super collectionName, (err, collection) =>
			# only call cb if we have collection
			if err or not collection
				wiz.log.err "unable to retrieve collection #{@config.database}.#{collectionName} #{err}"
				res.send 500, 'database failure'
				return null
			cb collection
	#}}}

class wiz.framework.http.database.mongo.base

	debug: false
	upsert: false
	collectionName: ''
	docKey: 'id'
	typeKey: 'type'
	dataKey: 'data'
	schema: {}

	constructor: (@server, @parent, @mongo) -> #{{{
		wiz.assert(@parent, "invalid @parent: #{@parent}")
		wiz.assert(@mongo, "invalid @mongo: #{@mongo}")
	#}}}
	init: () => #{{{
	#}}}

	criteria: (req) => #{{{ allow child class to override
		baseCriteria = {}
		return baseCriteria
	#}}}
	projection: (req) => #{{{ allow child class to override
		baseProjection =
			_id: 0
		return baseProjection
	#}}}

	getUpdateOptions: () => #{{{
		options =
			upsert: @upsert
		return options
	#}}}
	getDocKey: (id) => #{{{
		criteria = @criteria()
		criteria[@docKey] = id
		return criteria
	#}}}

	findAll: (req, res, cb) => #{{{
		criteria = @criteria()
		projection = @projection()
		opts = {}
		@find(req, res, criteria, projection, opts, cb)
	#}}}
	findOne: (req, res, criteria, projection, cb) => #{{{
		debugstr = "#{@collectionName}.findOne(#{JSON.stringify(criteria)}, #{JSON.stringify(projection)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			collection.findOne criteria, projection, (err, result) =>
				if err
					wiz.log.err "FINDONE FAILED: #{debugstr} -> #{err}"
					return cb req, res, null if cb
					return res.send 500

				wiz.log.info "FINDONE OK: #{debugstr}" if @debug
				wiz.log.debug "FINDONE RESULT: #{JSON.stringify(result)}" if @debug
				return cb req, res, result if cb
				res.send 200, result
	#}}}
	findOneByID: (req, res, id, cb) => #{{{
		criteria = @getDocKey(id)
		projection = @projection()
		@findOne req, res, criteria, projection, cb
	#}}}
	findOneByKey: (req, res, k, v, projection, cb) => #{{{
		criteria = {}
		criteria[k] = v
		@findOne req, res, criteria, projection, cb
	#}}}

	listResponse: (req, res, data, recordCount) => #{{{
		data = [] if not data or data not instanceof Array
		recordCount ?= data.length
		res.send 200,
			sEcho : req.query?.sEcho
			iTotalRecords : recordCount
			iTotalDisplayRecords : recordCount
			aaData : data
	#}}}

	updateCustom: (req, res, criteria, update, options, cb) => #{{{
		debugstr = "#{@collectionName}.update(#{JSON.stringify(criteria)}, #{JSON.stringify(update)}, #{JSON.stringify(options)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			collection.update criteria, update, options, (err, result) =>
				if err
					wiz.log.err "UPDATE FAILED: #{debugstr} -> #{err}"
					return cb null if cb
					return res.send 500

				wiz.log.info "UPDATE OK: #{debugstr}"
				return cb result if cb
				return res.send 200
	#}}}
	updateByID: (req, res, id, fieldsToUpdate, cb) => #{{{
		criteria = @criteria()
		criteria[@docKey] = id
		update =
			'$set':
				updated: wiz.framework.util.datetime.unixFullTS()
				data: fieldsToUpdate
		options = @getUpdateOptions()
		@updateCustom(req, res, criteria, update, options, cb)
	#}}}

	dropMany: (req, res, recordsToDelete, cb) => #{{{ send mongo criteria to drop a given array of mongo oid objects
		dropQuery =
			id : { $in : recordsToDelete }

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

	count: (req, res, criteria, projection, cb) => #{{{
		debugstr = "#{@collectionName}.count(#{JSON.stringify(criteria)}, #{JSON.stringify(projection)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			collection.find(criteria, projection).count (err, count) =>
				if err
					wiz.log.err "COUNT FAILED: #{debugstr} -> #{err}"
					return cb null if cb
					return res.send 500

				wiz.log.info "COUNT OK: #{debugstr}"
				return cb count if cb
				return res.send 200
	#}}}
	find: (req, res, criteria, projection, opts = {}, cb) => #{{{
		wiz.assert(criteria, "invalid criteria: #{criteria}")
		wiz.assert(projection, "invalid projection: #{projection}")
		wiz.assert(opts, "invalid opts: #{opts}")
		debugstr = "#{@collectionName}.find(#{JSON.stringify(criteria)}, #{JSON.stringify(projection)}, #{JSON.stringify(opts)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			found = collection.find(criteria, projection, opts)
			found.toArray (err, results) =>
				if err
					wiz.log.err "FIND FAILED: #{debugstr} -> #{err}"
					return cb null if cb
					return res.send 500

				wiz.log.info "FIND OK: #{debugstr}" if @debug
				return cb results if cb
				return res.send 200, results
	#}}}
	list: (req, res, userType) => #{{{
		return res.send 400, 'invalid type' if not schemaType = @schema.types[userType]

		criteria = @criteria()
		criteria[@typeKey] = schemaType[@typeKey]

		projection = @projection()
		opts =
			skip: if req.params.iDisplayStart then req.params.iDisplayStart else 0
			limit: if req.params.iDisplayLength > 0 and req.params.iDisplayLength < 200 then req.params.iDisplayLength else 25

		@count req, res, criteria, projection, (recordCount) =>
			@find req, res, criteria, projection, opts, (results) =>
				responseData = []
				if not results or not results.length > 0
					return @listResponse(req, res, responseData)

				for result in results
					if result[@dataKey] and typeof result[@dataKey] is 'object'
						responseData.push(result)

				@listResponse(req, res, responseData, recordCount)
	#}}}
	insert: (req, res, criteria, cb) => #{{{
		debugstr = "#{@collectionName}.insert(#{JSON.stringify(criteria)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			collection.insert criteria.toJSON(), (err, criteria) =>
				if err
					wiz.log.err "INSERT FAILED: #{debugstr} -> #{err}"
					return cb null if cb
					return res.send 500

				wiz.log.info "INSERT OK: #{debugstr}"
				return cb criteria if cb
				return res.send 200
	#}}}
	update: (req, res, id) => #{{{
		criteria = @criteria()
		criteria[@docKey] = id
		projection = @projection()
		@findOne req, res, criteria, projection, (req, res, result) =>
			# verify existing record exists
			return res.send 404 unless result and result[@docKey]

			# get existing record data
			objToUpdate = result[@dataKey]

			# validate user provided update object
			return unless userUpdate = @schema.fromUser(req, res, result[@typeKey], req.body[@dataKey], true)

			# update fields from post-validated user provided object
			for datum of userUpdate[@dataKey]
				objToUpdate[datum] = userUpdate[@dataKey][datum]

			# pass update object to super
			@updateByID req, res, result[@docKey], objToUpdate
	#}}}
	drop: (req, res, cb) => #{{{ default drop ajax handler
		# TODO: need extensible method (send event?) for other modules to delete related objects from their databases onUserDeleted
		return res.send 400 if not req.body.recordsToDelete or typeof req.body.recordsToDelete isnt 'object' # only proceed if object

		recordsToDelete = []
		if req.body.recordsToDelete and req.body.recordsToDelete.length > 0
			for id, i in req.body.recordsToDelete
				recordsToDelete[i] = @mongo.oid(id)
		@dropMany req, res, recordsToDelete, cb
	#}}}

class wiz.framework.http.database.mongo.baseArray extends wiz.framework.http.database.mongo.base

	arrayKey: ''
	elementKey: 'id'

	criteria: (req) => #{{{
		baseCriteria = super(req)
		if @typeKey and @arrayKey
			baseCriteria[@typeKey] = @arrayKey
		return baseCriteria
	#}}}
	projection: (req) => #{{{
		baseProjection = super(req)
		if @arrayKey
			baseProjection[@arrayKey] = 1
		return baseProjection
	#}}}

	getDocKeyWithElementID: (criteriaID, elementID) => #{{{
		criteria = @getDocKey(criteriaID)
		criteria[@arrayKey] = {}
		criteria[@arrayKey].$elemMatch = {}
		criteria[@arrayKey].$elemMatch[@elementKey] = elementID
		return criteria
	#}}}
	getArrayKey: (keys = [ @arrayKey ]) => #{{{
		projection = {}
		projection[key] = 1 for key in keys
		return projection
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
		toPush[pushKey] = objToPush#.toDB(req)
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

	findElementByID: (req, res, criteriaID, elementID, cb) => #{{{
		return cb(null) if not criteriaID or not elementID
		@findElementByCustom(req, res, @getDocKeyWithElementID(criteriaID, elementID), @getArrayKey(), @elementKey, elementID, cb)
	#}}}
	findElementByCustom: (req, res, criteria, projection, elementKey, elementID, cb) => #{{{
		@findOne req, res, criteria, projection, (req, res, result) =>
			if result and result[@arrayKey]
				for ri of result[@arrayKey] when r = result[@arrayKey][ri]
					if r[elementKey] == elementID
						return cb(r)
			return cb(null)
	#}}}

	findOneElementByKeyFromAllDocuments: (req, res, value, cb) => #{{{
		criteria = @criteria()
		criteria["#{@arrayKey}#{@elementKey}"] = value
		projection = @projection()
		projection[@arrayKey] = {}
		projection[@arrayKey]['$elemMatch'] = {}
		projection[@arrayKey]['$elemMatch'][@elementKey] = value
		@findOne(req, res, criteria, projection, cb)
	#}}}
	findElementsByKeyFromAllDocuments: (req, res, value, cb) => #{{{
		criteria = @criteria()
		criteria["#{@arrayKey}.#{@elementKey}"] = value
		projection = @projection()
		@find(req, res, criteria, projection, cb)
	#}}}
	findByArrayElementKey: (req, res, value, cb) => #{{{
		criteria = @criteria()
		criteria["#{@arrayKey}.#{@elementKey}"] = value
		projection = @projection()
		opts = {}
		@find(req, res, criteria, projection, opts, cb)
	#}}}

	list: (req, res, id) => #{{{
		@findOne req, res, @getDocKey(id), @getArrayKey(), (results) =>
			responseData = []
			if not results or not results[@arrayKey] or not results[@arrayKey].length > 0
				return @listResponse(req, res, responseData)

			results[@arrayKey].sort (a, b) =>
				if a[@elementKey] and b[@elementKey]
					return -1 if a[@elementKey] < b[@elementKey]
					return 1 if a[@elementKey] > b[@elementKey]
				return 0

			for result in results
				if result[@dataKey] and typeof result[@dataKey] is 'object'
					responseData.push(result)

			@listResponse(req, res, responseData, responseData.length)
	#}}}

	insertElementCustom: (req, res, criteriaID, objToInsert, cb) => #{{{
		criteria = @getDocKey criteriaID
		update = @getUpdatePushArray req, objToInsert
		options = @getUpdateOptions()
		@updateCustom(req, res, criteria, update, options, cb)
	#}}}
	insertElement: (req, res, type) => #{{{
		return unless recordToInsert = @schema.fromUser(req, res, type, req.body.data)
		@insertElementCustom req, res, type, recordToInsert
	#}}}

	dropMany: (req, res, criteriaID, elementID, objsToDelete, pullKey = null) => #{{{
		@mongo.collection res, @collectionName, (collection) =>
			# count records to drop
			pending = 0
			for t, toDelete of objsToDelete
				pending += 1

			# for each type in object, make criteria with given array
			for t, toDelete of objsToDelete
				# TODO: check permissions!!
				if elementID
					criteria = @getDocKeyWithElementID(criteriaID, elementID)
				else
					criteria = @getDocKey(criteriaID)
				update = @getUpdatePullArray(req, toDelete, pullKey)
				options = @getUpdateOptions()
				@updateCustom req, res, criteria, update, options, (result) =>
					res.send 200 if (pending -= 1) == 0
	#}}}

# vim: foldmethod=marker wrap
