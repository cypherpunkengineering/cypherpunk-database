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

	debug: false

	constructor: (@parent, @mongo) ->
		wizassert(false, "invalid @parent: #{@parent}") if not @parent
		wizassert(false, "invalid @mongo: #{@mongo}") if not @mongo

	collectionName: ''
	docKey: ''

	init: () =>

	getDocKey: (id) =>
		doc = {}
		doc[@docKey] = id
		return doc

	findOne: (req, res, doc, select, cb) =>
		wizlog.debug @constructor.name, "#{@collectionName}.findOne(#{JSON.stringify(doc)}, #{JSON.stringify(select)})" if @debug
		@mongo.collection res, @collectionName, (collection) =>
			collection.findOne(doc, select, cb)

	updateCustom: (req, res, doc, update, options, cb) =>
		debugstr = "#{@collectionName}.update(#{JSON.stringify(doc)}, #{JSON.stringify(update)}, #{JSON.stringify(options)})"
		wizlog.debug @constructor.name, debugstr if @debug
		@mongo.collection res, @collectionName, (collection) =>
			collection.update doc, update, options, (err, result) =>
				if err
					wizlog.err @constructor.name, "UPDATE FAILED: #{debugstr} -> #{err}"
					return cb false if cb
					return res.send 500

				wizlog.info @constructor.name, "UPDATE OK: #{debugstr}"
				return cb true if cb
				return res.send 200

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
