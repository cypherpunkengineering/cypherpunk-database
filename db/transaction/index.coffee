# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require './schema'

wiz.package 'cypherpunk.backend.db.transaction'

class cypherpunk.backend.db.transaction extends wiz.framework.http.database.mongo.baseArray
	collectionName: 'transaction'
	debug: true
	schema: cypherpunk.backend.db.transaction.schema
	upsert: false
	txidKey: 'txid'

	# DataTable methods
	list: (req, res, transactionType) => #{{{
		return res.send 400, 'invalid type' if not schemaType = @schema.types[transactionType]

		criteria = @criteria(req)
		criteria[@typeKey] = schemaType[@typeKey]

		projection = @projection()
		opts =
			skip: if req.params.iDisplayStart then req.params.iDisplayStart else 0
			limit: if req.params.iDisplayLength > 0 and req.params.iDisplayLength < 200 then req.params.iDisplayLength else 25
			sort: 'data.fullname'

		@count req, res, criteria, projection, (recordCount) =>
			@find req, res, criteria, projection, opts, (results) =>
				responseData = []
				if not results or not results.length > 0
					return @listResponse(req, res, responseData)

				for result in results
					if result[@dataKey] and typeof result[@dataKey] is 'object'
						responseData.push
							DT_RowId : result[@docKey]
							0: result[@docKey] or 'unknown'
							1: result[@dataKey].fullname or ''
							2: result[@dataKey].email or ''
							3: result.lastLoginTS or 0

				@listResponse(req, res, responseData, recordCount)
	#}}}
	insert: (req, res, recordToInsert = null, cb = null) => #{{{
		if recordToInsert is null
			return unless recordToInsert = @schema.fromUser(req, res, req.body.insertSelect, req.body[@dataKey])

		return super(req, res, recordToInsert, cb) if cb != null

		console.log 'recordToInsert is:'
		console.log recordToInsert

		super req, res, recordToInsert, (result) =>
			res.send 200
	#}}}
	drop: (req, res) => #{{{
		return res.send 501 # TODO: implement drop
		# TODO: need extensible method (send event?) for other modules to delete related objects from their databases onUserDeleted
		# return res.send 400 if not recordsToDelete = req.body.recordsToDelete or typeof recordsToDelete isnt 'object' # only proceed if object
		# @dropMany req, res, req.session.account[@docKey], null, recordsToDelete
	#}}}

	# custom APIs
	findOneByTXID: (req, res, txid, cb) => #{{{
		@findOneByKey req, res, "#{@dataKey}.#{@txidKey}", txid, @projection(), cb
	#}}}

# vim: foldmethod=marker wrap
