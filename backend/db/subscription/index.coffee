# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require './schema'

wiz.package 'cypherpunk.backend.db.subscription'

class cypherpunk.backend.db.subscription extends wiz.framework.http.database.mongo.baseArray
	collectionName: 'subscription'
	debug: true
	schema: cypherpunk.backend.db.subscription.schema
	upsert: false
	txidKey: 'txid'

	# DataTable methods
	list: (req, res, subscriptionType) => #{{{
		return res.send 400, 'invalid type' if not schemaType = @schema.types[subscriptionType]

		criteria = @criteria(req)
		criteria[@typeKey] = schemaType[@typeKey]

		projection = @projection()
		opts =
			skip: parseInt(if req.params.iDisplayStart then req.params.iDisplayStart else 0)
			limit: parseInt(if req.params.iDisplayLength > 0 and req.params.iDisplayLength < 200 then req.params.iDisplayLength else 25)
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
	drop: (req, res) => #{{{
		return res.send 501
	#}}}

	# custom APIs
	# public stranger APIs
	signup: (req, res, subscriptionData, cb) => #{{{
		return unless recordToInsert = @schema.fromStranger(req, res)
		if subscriptionData?[@schema.confirmedKey]?
			recordToInsert[@dataKey][@schema.confirmedKey] = subscriptionData[@schema.confirmedKey]
		if subscriptionData?[@schema.subscriptionPlanKey]?
			recordToInsert[@dataKey][@schema.subscriptionPlanKey] = subscriptionData[@schema.subscriptionPlanKey]
		if subscriptionData?[@schema.subscriptionRenewalKey]?
			recordToInsert[@dataKey][@schema.subscriptionRenewalKey] = subscriptionData[@schema.subscriptionRenewalKey]
		if subscriptionData?[@schema.subscriptionExpirationKey]?
			recordToInsert[@dataKey][@schema.subscriptionExpirationKey] = subscriptionData[@schema.subscriptionExpirationKey]
		@insert req, res, recordToInsert, cb
	#}}}

	fromStripePurchase: (req, res, recordToInsert = null, cb = null) => #{{{
		if recordToInsert is null
			return unless recordToInsert = @schema.fromUser(req, res, 'stripe', req.body[@dataKey])

		return super(req, res, recordToInsert, cb) if cb != null

		super req, res, recordToInsert, (result) =>
			res.send 200
	#}}}
	findOneByTXID: (req, res, txid, cb) => #{{{
		@findOneByKey req, res, "#{@dataKey}.#{@txidKey}", txid, @projection(), cb
	#}}}

# vim: foldmethod=marker wrap
