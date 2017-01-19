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

	# DataTable methods
	list: (req, res, subscriptionType) => #{{{
		return res.send 400, 'invalid type' if not schemaType = @schema.types[subscriptionType]

		criteria = @criteria(req)
		criteria[@typeKey] = schemaType[@typeKey]

		projection = @projection()
		opts =
			skip: parseInt(if req.params.iDisplayStart then req.params.iDisplayStart else 0)
			limit: parseInt(if req.params.iDisplayLength > 0 and req.params.iDisplayLength < 200 then req.params.iDisplayLength else 25)
			sort: "#{@dataKey}.#{@schema.purchaseTSKey}"

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
							1: result[@dataKey][@schema.providerKey] or ''
							2: result[@dataKey][@schema.providerPlanIDKey] or ''
							3: result[@dataKey][@schema.purchaseTSKey] or 0

				@listResponse(req, res, responseData, recordCount)
	#}}}
	drop: (req, res) => #{{{
		return res.send 501
	#}}}

	@calculatePrice: (plan) => #{{{
		if plan[0...7] == "monthly"
			return "8.99"
		else if plan[0...12] == "semiannually"
			return "44.99"
		else if plan[0...8] == "annually"
			return "59.99"
		else
			return null
	#}}}
	@calculateType: (plan) => #{{{
		if plan[0...7] == "monthly"
			return 'monthly'
		else if plan[0...12] == "semiannually"
			return 'semiannually'
		else if plan[0...8] == "annually"
			return 'annually'
		else
			return null
	#}}}
	@calculateRenewal: (plan) => #{{{
		subscriptionStart = new Date()
		subscriptionRenewal = new Date(+subscriptionStart)

		if plan[0...7] == "monthly"
			subscriptionRenewal.setDate(subscriptionStart.getDate() + 30)
		else if plan[0...12] == "semiannually"
			subscriptionRenewal.setDate(subscriptionStart.getDate() + 180)
		else if plan[0...8] == "annually"
			subscriptionRenewal.setDate(subscriptionStart.getDate() + 365)
		else
			return 0
		return subscriptionRenewal.toISOString()
	#}}}

	insert: (req, res, subscriptionType, subscriptionData = null, cb = null) => #{{{
		return unless recordToInsert = @schema.fromUser(req, res, subscriptionType, subscriptionData)
		super req, res, recordToInsert, (req2, res2, result) =>
			result = result[0] if result instanceof Array
			return cb(req2, res2, result) if cb
			res.send 200
	#}}}
	findOneByTXID: (req, res, txid, cb) => #{{{
		@findOneByKey req, res, "#{@dataKey}.#{@txidKey}", txid, @projection(), cb
	#}}}

# vim: foldmethod=marker wrap
