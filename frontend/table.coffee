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
require '../db'
require '../util/strval'

wizpackage 'wiz.framework.frontend.table'

class wiz.framework.frontend.table.dbobj #{{{

	constructor: () ->
		# implement in child class

	immutable: false

	toDB: (req) ->
		# add timestamps
		@updated ?= wiz.framework.util.datetime.unixFullTS()
		@created ?= @updated
		# create unique id using headers/session data as salt
		@id ?= wiz.framework.util.hash.digest
			payload: this
			headers: req.headers
			session: req.session
		return this

	toJSON: () =>
		return this
#}}}

class wiz.framework.frontend.table.base #{{{

	constructor: (@parent, @mongo) ->
		wizassert(false, "invalid @parent: #{@parent}") if not @parent
		wizassert(false, "invalid @mongo: #{@mongo}") if not @mongo

	collectionName: ''
	docKey: ''

	getDocKey: (id) =>
		doc = {}
		doc[@docKey] = id
		return doc

	findOne: (req, res, doc, select, cb) =>
		@mongo.collection res, @collectionName, (collection) =>
			collection.findOne(doc, select, cb)

	listResponse: (req, res, data) =>
		data = [] if not data or data not instanceof Array
		res.send
			sEcho : req.query.sEcho
			iTotalRecords : data.length
			iTotalDisplayRecords : data.length
			aaData : data

#}}}

class wiz.framework.frontend.table.baseArray extends wiz.framework.frontend.table.base #{{{

	arrayKey: ''
	elementKey: ''

	getDocKeyWithElementID: (docID, elementID) =>
		doc = {}
		doc[@docKey] = docID
		doc[@arrayKey] = {}
		doc[@arrayKey].$elemMatch = {}
		doc[@arrayKey].$elemMatch[@elementKey] = elementID
		return doc

	getArrayKey: () =>
		select = {}
		select[@arrayKey] = 1
		return select

	getUpdatePushArray: (req, objToPush) =>
		toPush = {}
		toPush[@arrayKey] = objToPush.toDB(req)
		update =
			'$set' : { updated: wiz.framework.util.datetime.unixFullTS() }
			'$push': toPush
		return update

	getUpdatePullArray: (req, objsToPull) =>
		toPull = {}
		toPull[@arrayKey] =
			id: objsToPull
			immutable: false # if not-admin
		update =
			'$set' : { updated: wiz.framework.util.datetime.unixFullTS() }
			'$pull': toPull
		return update

	getUpdateOptions: () =>
		options =
			upsert: true
		return options

	findElementByID: (req, res, docID, elementID, cb) =>
		return cb(null) if not docID or not elementID
		@findElementByCustom(req, res, @getDocKeyWithElementID(docID, elementID), @getArrayKey(), @elementKey, elementID, cb)

	findElementByCustom: (req, res, where, select, elementKey, elementID, cb) =>
		@findOne req, res, where, select, (err, result) =>
			if result and result[@arrayKey]
				for ri of result[@arrayKey] when r = result[@arrayKey][ri]
					if r[elementKey] == elementID
						return cb(r)
			return cb(null)

	insertOne: (req, res, docID, objToInsert) =>
		@mongo.collection res, @collectionName, (collection) =>
			doc = @getDocKey docID
			update = @getUpdatePushArray req, objToInsert
			options = @getUpdateOptions()
			collection.update doc, update, options, (err, result) =>
				if err
					wizlog.err @constructor.name, "UPDATE FAILED: PUSH #{JSON.stringify(doc)}, #{JSON.stringify(update)}, #{JSON.stringify(options)} -> #{err}"
					return res.send 500

				wizlog.info @constructor.name, "UPDATE OK: PUSH #{objToInsert.id}"
				return res.send 200

	modifyOne: (req, res, docID, objToModify) =>
		res.send 501

	dropMany: (req, res, docID, objsToDelete) =>
		@mongo.collection res, @collectionName, (collection) =>
			doc = @getDocKey(docID)
			options = @getUpdateOptions()

			# count records to drop
			pending = 0
			for t, toDelete of objsToDelete
				pending += 1

			# for each type in object, make query with given array
			for t, toDelete of objsToDelete
				update = @getUpdatePullArray req, toDelete
				collection.update doc, update, options, (err, result) =>
					if err
						wizlog.err @constructor.name, "UPDATE FAILED: #{JSON.stringify(doc)}, #{JSON.stringify(update)}, #{JSON.stringify(options)} -> #{err}"
					else
						wizlog.info @constructor.name, "UPDATE OK: PULL #{toDelete}"
					res.send 200 if (pending -= 1) == 0
#}}}

# vim: foldmethod=marker wrap
