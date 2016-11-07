# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require './schema'

wiz.package 'cypherpunk.backend.db.customer'

class cypherpunk.backend.db.customer extends wiz.framework.http.account.db.customers
	schema: cypherpunk.backend.db.customer.schema
	debug: true
	upsert: false
	passwordKey: 'password'
	passwordOldKey: 'passwordOld'

	# DataTable methods
	findOneByID: (req, res, id, cb) => #{{{ removes password hash
		super req, res, id, (req, res, result) =>
			return cb(null) if not result and cb
			return res.send 404 if not result
			if result[@dataKey]?
				result[@dataKey][@passwordKey] = ''
			return cb(result) if result and cb
			return res.send 200, result
	#}}}
	list: (req, res, customerPlan) => #{{{
		return res.send 400, 'invalid type' if not schemaPlan = @schema.types[customerPlan]

		criteria = @criteria(req)
		criteria[@typeKey] = schemaPlan[@typeKey]

		projection = @projection()
		opts =
			skip: if req.params.iDisplayStart then req.params.iDisplayStart else 0
			limit: if req.params.iDisplayLength > 0 and req.params.iDisplayLength < 200 then req.params.iDisplayLength else 25
			sort: "#{@dataKey}.#{@emailKey}"

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
							1: result[@dataKey][@emailKey] or ''
							2: result.lastLoginTS or 0

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
	updateUserData: (req, res, customerID, customerData, cb = null) => #{{{ restores password hash
		@findOneByKey req, res, @docKey, customerID, @projection(), (req, res, result) =>
			return cb(null) if not result and cb
			return res.send 404 if not result
			console.log result
			return res.send 500 if not result[@dataKey]?
			customerData[@passwordKey] = result[@dataKey][@passwordKey]
			@updateDataByID req, res, customerID, customerData, (req2, res2, result2) =>
				return cb(result2) if cb
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
		@findOne req, res, criteria, projection, (req, res, customerObj) =>
			# abort if existing password doesn't match
			if not customerObj?[@dataKey]?[@passwordKey]?
				err = 'missing customer password from db'
				wiz.log.err err
				return res.send 500, err

			# check if required args supplied
			if not passwordOld = req.body[@dataKey]?[@passwordOldKey]
				err = 'need existing password to change password'
				wiz.log.err err
				return res.send 400, err

			userPasswordHash = wiz.framework.http.account.authenticate.userpasswd.pwHash(passwordOld)
			dbPasswordHash = customerObj[@dataKey][@passwordKey]
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
