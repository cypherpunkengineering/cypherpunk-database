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

	@calculateType: (plan) =>
		if plan[0...7] == "monthly"
			type = 'monthly'
		else if plan[0...12] == "semiannually"
			type = 'semiannually'
		else if plan[0...8] == "annually"
			type = 'annually'
		else
			return null

	@calculateRenewal: (plan) =>
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

	findOneByTXID: (req, res, txid, cb) => #{{{
		@findOneByKey req, res, "#{@dataKey}.#{@txidKey}", txid, @projection(), cb
	#}}}

# vim: foldmethod=marker wrap
