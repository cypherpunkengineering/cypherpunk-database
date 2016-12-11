# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require './schema'

wiz.package 'cypherpunk.backend.db.affiliate'

class cypherpunk.backend.db.affiliate extends wiz.framework.http.database.mongo.baseArray
	collectionName: 'affiliate'
	schema: cypherpunk.backend.db.affiliate.schema
	debug: true
	upsert: false
	passwordKey: 'password'
	passwordOldKey: 'passwordOld'

	# DataTable methods
	findOneByID: (req, res, id, cb) => #{{{ removes password hash
		super req, res, id, (req2, res2, result) =>
			return cb(req2, res2, null) if not result and cb
			return res.send 404 if not result
			if result[@dataKey]?
				result[@dataKey][@passwordKey] = ''
			return cb(req2, res2, result) if result and cb
			return res.send 200, result
	#}}}
	list: (req, res, affiliatePlan) => #{{{
		return res.send 400, 'invalid type' if not schemaPlan = @schema.types[affiliatePlan]

		criteria = @criteria(req)
		criteria[@typeKey] = schemaPlan[@typeKey]

		projection = @projection()
		opts =
			skip: parseInt(if req.params.iDisplayStart then req.params.iDisplayStart else 0)
			limit: parseInt(if req.params.iDisplayLength > 0 and req.params.iDisplayLength < 200 then req.params.iDisplayLength else 25)
			sort: "#{@dataKey}.#{@emailKey}"

		@count req, res, criteria, projection, (req2, res2, recordCount) =>
			@find req, res, criteria, projection, opts, (req3, res3, results) =>
				responseData = []
				if not results or not results.length > 0
					return @listResponse(req, res, responseData)

				for result in results
					if result[@dataKey] and typeof result[@dataKey] is 'object'
						responseData.push
							DT_RowId : result[@docKey]
							0: result[@docKey] or 'unknown'
							1: result[@dataKey][@emailKey] or ''
							2: result.lastLoginTS or 0

				@listResponse(req, res, responseData, recordCount)
	#}}}
	insert: (req, res, recordToInsert = null, cb = null) => #{{{
		if recordToInsert is null
			return unless recordToInsert = @schema.fromUser(req, res, req.body.insertSelect, req.body[@dataKey])

		return super(req, res, recordToInsert, cb) if cb

		super req, res, recordToInsert, (req2, res2, result) =>
			return cb(req2, res2, result) if cb
			res.send 200
	#}}}
	updateUserData: (req, res, affiliateID, affiliateData, cb = null) => #{{{ restores password hash
		@findOneByKey req, res, @docKey, affiliateID, @projection(), (req, res, result) =>
			return cb(req, res, null) if not result and cb
			return res.send 404 if not result
			console.log result
			return res.send 500 if not result[@dataKey]?
			affiliateData[@passwordKey] = result[@dataKey][@passwordKey]
			@updateDataByID req, res, affiliateID, affiliateData, (req2, res2, result2) =>
				return cb(req2, res2, result2) if cb
				return res.send 500 if not result2
				return res.send 200
	#}}}
	updateCurrentUserData: (req, res, cb = null) => #{{{
		@updateUserData(req, res, req.session.account.id, req.session.account.data, cb)
	#}}}
	drop: (req, res) => #{{{
		return res.send 501 # TODO: implement drop
		# TODO: need extensible method (send event?) for other modules to delete related objects from their databases onUserDeleted
		# return res.send 400 if not recordsToDelete = req.body.recordsToDelete or typeof recordsToDelete isnt 'object' # only proceed if object
		# @dropMany req, res, req.session.account[@docKey], null, recordsToDelete
	#}}}

	# custom APIs
	findOneByEmail: (req, res, email, cb) => #{{{
		@findOneByKey req, res, "#{@dataKey}.#{@emailKey}", email, @projection(), cb
	#}}}

	myAccountPassword: (req, res) => #{{{
		# check if no session
		#return res.send 401, 'missing session id' if not req.session?.account?.id?
		if not passwordNew = req.body[@dataKey]?[@passwordKey]
			return res.send 400, 'missing password'

		# mongo criteria is account id
		criteria = @getDocKey(req, req.session.account.id)
		# get full projection
		projection = @projection()
		@findOne req, res, criteria, projection, (req, res, affiliateObj) =>
			# abort if existing password doesn't match
			if not affiliateObj?[@dataKey]?[@passwordKey]?
				err = 'missing affiliate password from db'
				wiz.log.err err
				return res.send 500, err

			# check if required args supplied
			if not passwordOld = req.body[@dataKey]?[@passwordOldKey]
				err = 'need existing password to change password'
				wiz.log.err err
				return res.send 400, err

			userPasswordHash = wiz.framework.http.account.authenticate.userpasswd.pwHash(passwordOld)
			dbPasswordHash = affiliateObj[@dataKey][@passwordKey]
			if userPasswordHash != dbPasswordHash
				err = 'existing password is incorrect'
				wiz.log.err err
				return res.send 400, err

			# update
			@update(req, res, req.session.account.id)
	#}}}
	myAccountDetails: (req, res) => #{{{
		@update(req, res, req.session.account.id)
	#}}}

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

# vim: foldmethod=marker wrap
