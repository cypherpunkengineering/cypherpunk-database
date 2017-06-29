# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require './schema'

wiz.package 'cypherpunk.backend.db.receipt'

class cypherpunk.backend.db.receipt extends wiz.framework.http.database.mongo.baseArray
	collectionName: 'receipt'
	debug: true
	schema: cypherpunk.backend.db.receipt.schema
	upsert: false

	# DataTable methods
	list: (req, res, receiptType) => #{{{
		return res.send 400, 'invalid type' if not schemaType = @schema.types[receiptType]

		criteria = @criteria(req)
		criteria[@schema.typeKey] = schemaType[@schema.typeKey]

		projection = @projection()
		opts =
			skip: parseInt(if req.params.iDisplayStart then req.params.iDisplayStart else 0)
			limit: parseInt(if req.params.iDisplayLength > 0 and req.params.iDisplayLength < 200 then req.params.iDisplayLength else 25)
			sort: 'data.fullname'

		@count req, res, criteria, projection, (req, res, recordCount) =>
			@find req, res, criteria, projection, opts, (req, res, results) =>
				responseData = []
				if not results or not results.length > 0
					return @listResponse(req, res, responseData)

				for result in results
					if result[@dataKey] and typeof result[@dataKey] is 'object'
						responseData.push
							DT_RowId : result[@schema.docKey]
							0: result[@schema.docKey] or 'unknown'
							1: result[@dataKey].fullname or ''
							2: result[@dataKey].email or ''
							3: result.lastLoginTS or 0

				@listResponse(req, res, responseData, recordCount)
	#}}}
	drop: (req, res) => #{{{
		return res.send 501
	#}}}

	# custom APIs
	create: (req, res, recordToInsert = null, cb = null) => #{{{
		if recordToInsert is null
			return unless recordToInsert = @schema.fromUser(req, res, req.body.insertSelect, req.body[@dataKey])

		return @insert(req, res, recordToInsert, cb) if cb != null

		@insert req, res, recordToInsert, (result) =>
			res.send 200
	#}}}
	createChargeReceipt: (req, res, receiptData = null, cb = null) => #{{{
		return unless recordToInsert = @schema.fromUser(req, res, 'charge', receiptData)
		@insert(req, res, recordToInsert, cb)
	#}}}
	getReceiptsForCurrentUser: (req, res, cb) => #{{{
		criteria = @criteria(req)
		criteria[@typeKey] = 'charge'
		criteria["#{@dataKey}.#{@schema.accountIDkey}"] = req.session.account.id
		projection = @projection()
		opts =
			#skip: parseInt(if req.params.iDisplayStart then req.params.iDisplayStart else 0)
			#limit: parseInt(if req.params.iDisplayLength > 0 and req.params.iDisplayLength < 200 then req.params.iDisplayLength else 25)
			sort:
				"#{@dataKey}.#{@schema.paymentTSkey}": -1

		@count req, res, criteria, projection, (req2, res2, recordCount) =>
			@find req, res, criteria, projection, opts, (req3, res3, results) =>
				# prepare response structure
				out =
					receiptCount: recordCount
					receipts: []

				# if no results just send empty structure
				if not results or not results.length > 0
					return res.send 200, out

				# iterate
				for result in results
					if result[@dataKey] and typeof result[@dataKey] is 'object'
						out.receipts.push
							id: result[@schema.docKey]
							date: result[@dataKey][@schema.paymentTSkey] or 'unknown'
							description: result[@dataKey][@schema.descriptionKey] or ''
							method: result[@dataKey][@schema.methodKey] or ''
							currency: result[@dataKey][@schema.currencyKey] or 0
							amount: result[@dataKey][@schema.amountKey] or 0

				return res.send 200, out
	#}}}
	findOneByTXID: (req, res, transactionID, cb) => #{{{
		@findOneByKey req, res, "#{@dataKey}.#{@transactionIDKey}", transactionID, @projection(), cb
	#}}}

# vim: foldmethod=marker wrap
