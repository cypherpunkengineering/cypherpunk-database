# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require './schema'

wiz.package 'cypherpunk.backend.db.user'

class cypherpunk.backend.db.user extends wiz.framework.http.account.db.user
	schema: cypherpunk.backend.db.user.schema
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
	list: (req, res, userPlan) => #{{{
		return res.send 400, 'invalid type' if not schemaPlan = @schema.types[userPlan]

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

		super req, res, recordToInsert, (req2, res2, result) =>
			result = result[0] if result instanceof Array
			@server.root.api.radius.database.updateUserAccess req, res, result, (err) =>
				if err
					wiz.log.err(err)
					return res.send 500, 'Unable to update database'

				return cb(req2, res2, result) if cb
				res.send 200
	#}}}
	update: (req, res, userID) => #{{{
		# TODO: return res.send 400, 'invalid type' if not schemaPlan = @schema.types[userPlan]
		super req, res, userID, (req2, res2, result) =>
			return res.send 500, "update database failed" if not result
			@findOneByKey req, res, @docKey, userID, @projection(), (req, res, user) =>
				@server.root.api.radius.database.updateUserAccess req, res, user, (err) =>
					return res.send 500, "update database failed" if err
					return res.send 200
	#}}}
	updateUserData: (req, res, userID, userData, cb = null) => #{{{ restores password hash
		@findOneByKey req, res, @docKey, userID, @projection(), (req, res, result) =>
			return cb(req, res, null) if not result and cb
			return res.send 404 if not result
			return res.send 500 if not result[@dataKey]?
			userData[@passwordKey] = result[@dataKey][@passwordKey]
			@updateDataByID req, res, userID, userData, (req2, res2, result2) =>
				if result2?.result?.ok != 1
					wiz.log.err 'DB Error while updating user data!'
					console.log result2
					return res.send 500
				# get freshly updated user object from db
				@findOneByKey req, res, @docKey, userID, @projection(), (req, res, result) =>
					return cb(req, res, null) if not result and cb
					return res.send 404 if not result
					return res.send 500 if not result[@dataKey]?
					# pass updated db object to radius database method
					@server.root.api.radius.database.updateUserAccess req, res, result, (err) =>
						if err
							wiz.log.err(err)
							return res.send 500, 'Unable to update database'

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
		@findOne req, res, criteria, projection, (req, res, userObj) =>
			# abort if existing password doesn't match
			if not userObj?[@dataKey]?[@passwordKey]?
				err = 'missing user password from db'
				wiz.log.err err
				return res.send 500, err

			# check if required args supplied
			if not passwordOld = req.body[@dataKey]?[@passwordOldKey]
				err = 'need existing password to change password'
				wiz.log.err err
				return res.send 400, err

			userPasswordHash = wiz.framework.http.account.authenticate.userpasswd.pwHash(passwordOld)
			dbPasswordHash = userObj[@dataKey][@passwordKey]
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
	signup: (req, res, data, cb) => #{{{
		return unless recordToInsert = @schema.fromStranger(req, res)
		if data?[@schema.confirmedKey]?
			recordToInsert[@dataKey][@schema.confirmedKey] = data[@schema.confirmedKey]
		if data?[@schema.stripeCustomerIDKey]?
			recordToInsert[@dataKey][@schema.stripeCustomerIDKey] = data[@schema.stripeCustomerIDKey]
		if data?[@schema.subscriptionCurrentIDKey]?
			recordToInsert[@dataKey][@schema.subscriptionCurrentIDKey] = data[@schema.subscriptionCurrentIDKey]
		@insert req, res, recordToInsert, cb
	#}}}
	upgrade: (req, res, userID, subscriptionID, cb = null) => #{{{ if user type is free, change to premium
		@findOneByKey req, res, @docKey, userID, @projection(), (req, res, user) =>
			return cb(req, res, null) if not user and cb
			return res.send 404 if not user
			return res.send 500 if not user[@dataKey]?
			dataset = {}
			dataset[@typeKey] = "premium" if user[@typeKey] == "free"
			dataset[@dataKey] = user[@dataKey]
			dataset[@dataKey][@schema.subscriptionCurrentIDKey] = subscriptionID
			@updateCustomDatasetByID req, res, userID, dataset, (req2, res2, result2) =>
				if result2?.result?.ok != 1
					wiz.log.err 'DB Error while updating user data!'
					console.log result2
					return res.send 500
				# get freshly updated user object from db
				@findOneByKey req, res, @docKey, userID, @projection(), (req, res, result) =>
					return cb(req, res, null) if not result and cb
					return res.send 404 if not result
					return res.send 500 if not result[@dataKey]?
					wiz.log.info "Upgraded user account (free -> premium) for #{user[@dataKey][@emailKey]}"

					# pass updated db object to radius database method
					@server.root.api.radius.database.updateUserAccess req, res, result, (err) =>
						if err
							wiz.log.err(err)
							return res.send 500, 'Unable to update database'

						return cb(req, res, result) if cb
						return res.send 500 if not result2
						return res.send 200
	#}}}

# vim: foldmethod=marker wrap
