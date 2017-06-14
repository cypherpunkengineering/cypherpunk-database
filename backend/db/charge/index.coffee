# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require './schema'

wiz.package 'cypherpunk.backend.db.charge'

class cypherpunk.backend.db.charge extends wiz.framework.http.database.mongo.baseArray
	collectionName: 'charge'
	debug: true
	schema: cypherpunk.backend.db.charge.schema
	upsert: false
	txidKey: 'txid'

	# DataTable methods
	list: (req, res, chargeType) => #{{{
		return res.send 400, 'invalid type' if not schemaType = @schema.types[chargeType]

		criteria = @criteria(req)
		criteria[@typeKey] = schemaType[@typeKey]

		projection = @projection()
		opts =
			skip: parseInt(if req.params.iDisplayStart then req.params.iDisplayStart else 0)
			limit: parseInt(if req.params.iDisplayLength > 0 and req.params.iDisplayLength < 200 then req.params.iDisplayLength else 25)
			#sort: 'fullname'

		@count req, res, criteria, projection, (req, res, recordCount) =>
			@find req, res, criteria, projection, opts, (req, res, results) =>
				responseData = []
				if not results or not results.length > 0
					return @listResponse(req, res, responseData)

				for result in results
					if result[@dataKey] and typeof result[@dataKey] is 'object'
						responseData.push
							DT_RowId : result[@docKey]
							0: result[@docKey] or 'unknown'
							1: result[@dataKey].payer_email or ''
							2: result[@dataKey].mc_gross or ''
							3: result[@dataKey].payment_date or 0

				@listResponse(req, res, responseData, recordCount)
	#}}}
	drop: (req, res) => #{{{
		return res.send 501
	#}}}

	# custom APIs
	saveFromIPN: (req, res, type, data = null, cb = null) => #{{{
		return unless recordToInsert = @schema.fromUser(req, res, type, data)
		return @insert(req, res, recordToInsert, cb)
	#}}}
	findOneByTXID: (req, res, txid, cb) => #{{{
		@findOneByKey req, res, "#{@dataKey}.#{@txidKey}", txid, @projection(), cb
	#}}}

# vim: foldmethod=marker wrap
