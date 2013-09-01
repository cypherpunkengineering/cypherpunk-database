# copyright 2013 wiz technologies inc.

require '..'
require '../database/mongo'
require '../crypto/hash'
require '../util/strval'

wiz.package 'wiz.framework.http.table'

class wiz.framework.http.table.dbobj #{{{

	constructor: () ->
		# implement in child class

	immutable: false

	toDB: (req) ->
		# add timestamps
		@updated ?= wiz.framework.util.datetime.unixFullTS()
		@created ?= @updated
		# create unique id using headers/session data as salt
		@id ?= wiz.framework.crypto.hash.digest
			payload: this
			headers: req.headers
			session: req.session
		return this

	toJSON: () =>
		return this
#}}}

class wiz.framework.http.table.mongo #{{{

	debug: false
	upsert: true

	constructor: (@server, @parent, @mongo) ->
		wiz.assert(false, "invalid @parent: #{@parent}") if not @parent
		wiz.assert(false, "invalid @mongo: #{@mongo}") if not @mongo

	collectionName: ''
	docKey: ''

	init: () =>

	getDocKey: (id) =>
		doc = {}
		doc[@docKey] = id
		return doc

	# allow child class to override
	where: (req) =>
		return {}

	count: (req, res, doc, select, cb) =>
		debugstr = "#{@collectionName}.count(#{JSON.stringify(doc)}, #{JSON.stringify(select)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			collection.find(doc, select).count (err, count) =>
				if err
					wiz.log.err "COUNT FAILED: #{debugstr} -> #{err}"
					return cb null if cb
					return res.send 500

				wiz.log.info "COUNT OK: #{debugstr}"
				return cb count if cb
				return res.send 200

	find: (req, res, doc, select, sortby, cb) =>
		debugstr = "#{@collectionName}.find(#{JSON.stringify(doc)}, #{JSON.stringify(select)}, #{JSON.stringify(sortby)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			found = collection.find(doc, select)
			found = found.sort(sortby) if sortby
			found.toArray (err, results) =>
				if err
					wiz.log.err "FIND FAILED: #{debugstr} -> #{err}"
					return cb null if cb
					return res.send 500

				wiz.log.info "FIND OK: #{debugstr}" if @debug
				return cb results if cb
				return res.send 200

	findOne: (req, res, doc, select, cb) =>
		debugstr = "#{@collectionName}.findOne(#{JSON.stringify(doc)}, #{JSON.stringify(select)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			collection.findOne doc, select, (err, result) =>
				if err
					wiz.log.err "FINDONE FAILED: #{debugstr} -> #{err}"
					return cb null if cb
					return res.send 500

				wiz.log.info "FINDONE OK: #{debugstr}" if @debug
				# wiz.log.debug "FINDONE RESULT: #{JSON.stringify(result)}" if @debug
				return cb result if cb
				return res.send 200

	insert: (req, res, doc, cb) =>
		debugstr = "#{@collectionName}.insert(#{JSON.stringify(doc)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			collection.insert doc.toJSON(), (err, doc) =>
				if err
					wiz.log.err "INSERT FAILED: #{debugstr} -> #{err}"
					return cb null if cb
					return res.send 500

				wiz.log.info "INSERT OK: #{debugstr}"
				return cb doc if cb
				return res.send 200

	updateCustom: (req, res, doc, update, options, cb) =>
		debugstr = "#{@collectionName}.update(#{JSON.stringify(doc)}, #{JSON.stringify(update)}, #{JSON.stringify(options)})"
		wiz.log.debug debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			collection.update doc, update, options, (err, result) =>
				if err
					wiz.log.err "UPDATE FAILED: #{debugstr} -> #{err}"
					return cb null if cb
					return res.send 500

				wiz.log.info "UPDATE OK: #{debugstr}"
				return cb result if cb
				return res.send 200

	listResponse: (req, res, data, recordCount) =>
		data = [] if not data or data not instanceof Array
		recordCount ?= data.length
		res.send
			sEcho : req.query.sEcho
			iTotalRecords : recordCount
			iTotalDisplayRecords : recordCount
			aaData : data

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
#}}}

class wiz.framework.http.table.mongoArray extends wiz.framework.http.table.mongo #{{{

	arrayKey: ''
	elementKey: 'id'

	getDocKeyWithElementID: (docID, elementID) =>
		doc = @getDocKey(docID)
		doc[@arrayKey] = {}
		doc[@arrayKey].$elemMatch = {}
		doc[@arrayKey].$elemMatch[@elementKey] = elementID
		return doc

	getArrayKey: (keys = [ @arrayKey ]) =>
		select = {}
		select[key] = 1 for key in keys
		return select

	getUpdateSetObj: (req, objsToSet) =>
		update = {}
		update['$set'] = {}
		for k, v of objsToSet
			setKey = @arrayKey + '.$.' + k
			update['$set'][setKey] = v
			update['$set'][setKey].updated = wiz.framework.util.datetime.unixFullTS()
		return update

	getUpdatePushArray: (req, objToPush, pushKey) =>
		pushKey ?= @arrayKey
		toPush = {}
		toPush[pushKey] = objToPush.toDB(req)
		update =
			'$set' : { updated: wiz.framework.util.datetime.unixFullTS() }
			'$push': toPush
		return update

	getUpdatePullArray: (req, objToPull, pullKey) =>
		pullKey ?= @arrayKey
		toPull = {}
		toPull[pullKey] = {}
		toPull[pullKey][@elementKey] = objToPull
		toPull[pullKey].immutable = false # if not-admin
		update =
			'$set' : { updated: wiz.framework.util.datetime.unixFullTS() }
			'$pull': toPull
		return update

	getUpdateOptions: () =>
		options =
			upsert: @upsert
		return options

	findElementByID: (req, res, docID, elementID, cb) =>
		return cb(null) if not docID or not elementID
		@findElementByCustom(req, res, @getDocKeyWithElementID(docID, elementID), @getArrayKey(), @elementKey, elementID, cb)

	findElementByCustom: (req, res, where, select, elementKey, elementID, cb) =>
		@findOne req, res, where, select, (result) =>
			if result and result[@arrayKey]
				for ri of result[@arrayKey] when r = result[@arrayKey][ri]
					if r[elementKey] == elementID
						return cb(r)
			return cb(null)

	insertOne: (req, res, docID, objToInsert) =>
		doc = @getDocKey docID
		update = @getUpdatePushArray req, objToInsert
		options = @getUpdateOptions()
		@updateCustom(req, res, doc, update, options)

	modifyOne: (req, res, docID, objToModify) =>
		res.send 501

	dropMany: (req, res, docID, elementID, objsToDelete, pullKey = null) =>
		@mongo.collection res, @collectionName, (collection) =>
			# count records to drop
			pending = 0
			for t, toDelete of objsToDelete
				pending += 1

			# for each type in object, make query with given array
			for t, toDelete of objsToDelete
				# TODO: check permissions!!
				if elementID
					doc = @getDocKeyWithElementID(docID, elementID)
				else
					doc = @getDocKey(docID)
				update = @getUpdatePullArray(req, toDelete, pullKey)
				options = @getUpdateOptions()
				@updateCustom req, res, doc, update, options, (result) =>
					res.send 200 if (pending -= 1) == 0
#}}}

# vim: foldmethod=marker wrap
