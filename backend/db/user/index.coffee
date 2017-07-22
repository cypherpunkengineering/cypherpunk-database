# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

crypto = require 'crypto'
BigInteger = require './_framework/crypto/jsbn'

require './schema'

wiz.package 'cypherpunk.backend.db.user'

class cypherpunk.backend.db.user extends wiz.framework.http.account.db.user
	schema: cypherpunk.backend.db.user.schema
	debug: true
	upsert: false
	passwordKey: 'password'
	passwordOldKey: 'passwordOld'
	signupPriorityKey: 'signupPriority'

	# utility methods
	assignSignupPriority: (req) => #{{{
		try
			country = req.headers['x-geolocation-country'] or 'Unknown'
			tier = wiz.framework.util.world.countryPricingTier[country] or 1
		catch e
			country = "Unknown"
			tier = 1

		wiz.log.info "Country #{country} is tier #{tier}"
		return tier
	#}}}

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
							1: result[@typeKey] or ''
							2: result[@dataKey][@emailKey] or ''
							3: result.lastLoginTS or 0

				@listResponse(req, res, responseData, recordCount)
	#}}}
	createAccount: (req, res, recordToInsert = null, cb = null) => #{{{
		@findOneByEmail req, res, recordToInsert?[@dataKey]?[@emailKey], (req, res, result) =>
			return res.send 409, "Email already registered for #{recordToInsert?[@dataKey]?[@emailKey]}" if result isnt null

			@insert req, res, recordToInsert, (req2, res2, user) =>
				# dereference array
				user = user[0] if user instanceof Array

				# sanity check
				return res.send 500, 'Unable to create account' unless user?.data?.email?

				# debug print
				wiz.log.info "Created new user account for #{user.data.email}"

				# create radius database entries
				@server.root.api.radius.database.updateUserAccess req, res, user, (err) =>
					wiz.log.err 'Unable to update radius database: ', err if err?

				# create stripe customer object
				@server.root.stripe.customerCreateForAccount req, res, user, () =>
					# TODO: handle error

				return cb(req2, res2, user) if cb
				return res.send 200
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
			# check result
			return cb(req, res, null) if not result and cb
			return res.send 404 if not result
			return res.send 500 if not result[@dataKey]?
			# preserve password
			userData[@passwordKey] = result[@dataKey][@passwordKey]
			@updateDataByID req, res, userID, userData, (req, res, result2) =>
				# check result
				return res.send 500, 'DB Error while updating user data!', result2 if result2?.result?.ok != 1
				# get freshly updated user object from db
				@findOneByKey req, res, @docKey, userID, @projection(), (req, res, result) =>
					return cb(req, res, null) if not result and cb
					return res.send 404 if not result
					return res.send 500 if not result[@dataKey]?
					# pass updated db object to radius database method
					@server.root.api.radius.database.updateUserAccess req, res, result, (err) =>
						return res.send 500, 'Unable to update database', err if err?
						return cb(req, res, result) if cb?
						return res.send 500 if not result2
						return res.send 200
	#}}}
	updateCurrentUserData: (req, res, cb = null) => #{{{
		@updateUserData(req, res, req.session.account.id, req.session.account.data, cb)
	#}}}
	updateCurrentUserPassword: (req, res, passwordOld, passwordNew) => #{{{
		# mongo criteria is account id
		criteria = @getDocKey(req, req.session.account.id)

		# get full projection
		projection = @projection()

		# use findOne() instead of findOneByID() because latter removes password hash
		@findOne req, res, criteria, projection, (req, res, userObj) =>

			# abort if existing password doesn't exist
			if not userObj?[@dataKey]?[@passwordKey]?
				return res.send 500, 'missing user password from db'

			# check if passwordOld is actually the account password
			oldPasswordHash = wiz.framework.http.account.authenticate.userpasswd.pwHash(passwordOld)
			dbPasswordHash = userObj[@dataKey][@passwordKey]
			return res.send 400, 'Current password is incorrect' if oldPasswordHash != dbPasswordHash

			# create update object
			userData = {}
			userData[@passwordKey] = passwordNew

			# use update() since updating one field only
			@updateOneFromUser(req, res, req.session.account.id, userData)
	#}}}
	updateCurrentUserEmail: (req, res, password, pendingEmailAddress) => #{{{
		# check if email is already in use
		@findOneByEmail req, res, pendingEmailAddress, (req, res, resultUnused) =>
			return res.send 409, "Email already in use for #{pendingEmailAddress}" if resultUnused isnt null

			# mongo criteria is account id
			criteria = @getDocKey(req, req.session.account.id)

			# get full projection
			projection = @projection()

			# use findOne() instead of findOneByID() because latter removes password hash
			@findOne req, res, criteria, projection, (req, res, userObj) =>

				# check if password is actually the account password
				oldPasswordHash = wiz.framework.http.account.authenticate.userpasswd.pwHash(password)
				dbPasswordHash = userObj[@dataKey][@passwordKey]
				return res.send 400, 'Password is incorrect' if oldPasswordHash != dbPasswordHash

				# create update object
				dataset = {}

				# set new values
				dataset[@schema.pendingEmailKey] = pendingEmailAddress

				# generate pending email confirmation token
				bits = new BigInteger(crypto.randomBytes(16))
				dataset[@schema.pendingEmailConfirmationTokenKey] ?= wiz.framework.crypto.convert.biToBase32(bits)

				# update account db
				@updateCustomDatasetByID req, res, req.session.account.id, dataset, (req, res, writeResult) =>
					return res.send 500, "Database error", writeResult.result if writeResult?.result?.ok != 1

					# get updated user object
					@findOneByID req, res, req.session.account.id, (req, res, user) =>

						# send new confirmation email
						@server.root.sendgrid.sendChangeConfirmationMail(user)

						# done
						res.send 200
	#}}}
	drop: (req, res) => #{{{
		return res.send 501 # TODO: implement drop
		# TODO: need extensible method (send event?) for other modules to delete related objects from their databases onUserDeleted
		# return res.send 400 if not recordsToDelete = req.body.recordsToDelete or typeof recordsToDelete isnt 'object' # only proceed if object
		# @dropMany req, res, req.session.account[@docKey], null, recordsToDelete
	#}}}

	# custom methods
	findOneByStripeCustomerID: (req, res, stripeCustomerID, cb) => #{{{
		return cb(req, res, null) unless stripeCustomerID?
		@findOneByKey req, res, "#{@dataKey}.#{@schema.stripeCustomerIDKey}", stripeCustomerID, @projection(), cb
	#}}}
	signup: (req, res, recordToInsert, data, cb) => #{{{ creates a new account without validation
		# set optional parameters if given, used by payment gateway signup methods
		if data?[@schema.confirmedKey]?
			recordToInsert[@dataKey][@schema.confirmedKey] = data[@schema.confirmedKey]
		if data?[@schema.stripeCustomerIDKey]?
			recordToInsert[@dataKey][@schema.stripeCustomerIDKey] = data[@schema.stripeCustomerIDKey]
		if data?[@schema.amazonBillingAgreementIDKey]?
			recordToInsert[@dataKey][@schema.amazonBillingAgreementIDKey] = data[@schema.amazonBillingAgreementIDKey]
		if data?[@schema.subscriptionCurrentIDKey]?
			recordToInsert[@dataKey][@schema.subscriptionCurrentIDKey] = data[@schema.subscriptionCurrentIDKey]
		if data?[@schema.referralIDKey]?
			recordToInsert[@dataKey][@schema.referralIDKey] = data[@schema.referralIDKey]
		if data?[@schema.referralNameKey]?
			recordToInsert[@dataKey][@schema.referralNameKey] = data[@schema.referralNameKey]

		# insert the account into db
		@createAccount req, res, recordToInsert, (req, res, user) =>

			# send different email template depending on how user signed up
			switch user.type

				# teaser campaign
				when 'invitation'

					# send different email depending if referred or not

					if user?.referralID? # signed up by a friend
						@server.root.sendgrid.sendTeaserShareWithFriendMail(user)

					else # signed up by themself
						@server.root.sendgrid.sendTeaserMail(user)

					# send slack notification
					@server.root.slack.notify("[TEASER] #{user[@dataKey][@emailKey]} has signed up for a (priority #{user[@dataKey][@signupPriorityKey]}) invitation :highfive:")

				# trial account
				when 'free'

					# prepare data for subscription object creation
					subscriptionType = 'trial'
					subscriptionData =
						accountID: user?.id
						startTS: new Date()
						expirationTS: cypherpunk.backend.db.subscription.calculateRenewal(subscriptionType)
						active: 'true'
					console.log subscriptionData

					# insert free trial subscription object into db
					@server.root.api.subscription.database.insert req, res, subscriptionType, subscriptionData, (req, res, subscription) =>

						# send welcome email
						@server.root.sendgrid.sendWelcomeMail(user)

						# send slack notification
						@server.root.slack.notify("[SIGNUP] #{user[@dataKey][@emailKey]} has signed up for an account :highfive:")

				# for other account types
				else

					# send welcome email
					@server.root.sendgrid.sendWelcomeMail(user)

					# send slack notification
					@server.root.slack.notify("[SIGNUP] #{user[@dataKey][@emailKey]} has signed up for an account :highfive:")

			@count req, res, {}, {}, (req, res, count) =>
				@count req, res, { 'data.confirmed':true }, {}, (req, res, countConfirmed) =>

					# send db user count to slack
					if wiz.style isnt 'DEV'
						@server.root.slack.notify("[COUNT] Currently #{count} users registered, #{countConfirmed} users confirmed :alex:")

					# send response
					return cb(req, res, user) if cb?
					return res.send 202
	#}}}
	resendConfirmationEmail: (req, res, email, cb) => #{{{
		@findOneByEmail req, res, email, (req, res, user) =>
			# check for errors
			return res.send 404, 'email not registered' unless user?.id?

			# re-send confirmation email if account is not yet confirmed
			if user[@dataKey]?[@schema.confirmedKey]?.toString() is 'false'
				@server.root.sendgrid.sendWelcomeMail(user)
				@server.root.slack.notify("[RESEND] User #{user[@dataKey][@emailKey]} has requested re-send of confirmation email :love_letter:")

			return res.send 200
	#}}}
	recoverEmail: (req, res, email, cb) => #{{{
		@findOneByEmail req, res, email, (req, res, user) =>
			# check for errors
			return res.send 404, 'email not registered' unless user?.id?

			# create update object
			dataset = {}

			# generate random recovery token
			bits = new BigInteger(crypto.randomBytes(16))
			dataset[@schema.recoveryTokenKey] ?= wiz.framework.crypto.convert.biToBase32(bits)

			# update account db
			@updateCustomDatasetByID req, res, user.id, dataset, (req, res, writeResult) =>
				return res.send 500, 'Database error', writeResult.result if writeResult?.result?.ok != 1

				# get updated user object
				@findOneByID req, res, user.id, (req, res, user) =>

					# send new confirmation email
					@server.root.sendgrid.sendAccountRecoveryMail(user)

					# send slack notification
					@server.root.slack.notify("[RECOVER] User #{user[@dataKey][@emailKey]} has requested account recovery by email :love_letter:")

					# done
					return cb(req, res, user) if cb?
					return res.send 200
	#}}}
	recoverReset: (req, res, accountID, token, passwordNew, cb) => #{{{
		@findOneByID req, res, accountID, (req, res, user) =>
			# check for errors
			return res.send 404 unless user?
			return res.send 500 unless (user[@schema.recoveryTokenKey]? and typeof user[@schema.recoveryTokenKey] is "string")
			return res.send 403 unless (user[@schema.recoveryTokenKey].length > 1 && token == user[@schema.recoveryTokenKey])

			# mark as confirmed
			user[@dataKey][@schema.confirmedKey] = true

			# update user object in database
			@server.root.api.user.database.updateUserData req, res, accountID, user[@dataKey], (req, res, result) =>
				return res.send 500, 'Unable to confirm account' if not result?

				# create update object
				userData = {}
				userData[@passwordKey] = passwordNew

				# use update() since updating one field only
				@updateOneFromUser req, res, accountID, userData, (req, res, result2) =>
					if result2?.result?.ok != 1
						wiz.log.err 'DB Error while updating user data!'
						console.log result2
						return res.send 500

					# send slack notification
					@server.root.slack.notify("[RECOVER] User #{user[@dataKey][@emailKey]} has completed account recovery by email :+1:")

					# done
					return cb(req, res, user) if cb?
					return res.send 200
	#}}}
	confirm: (req, res, accountID, confirmationToken, cb) => #{{{
		@findOneByID req, res, accountID, (req, res, user) =>
			# check for errors
			return res.send 404 unless user?
			return res.send 500 unless (user[@schema.confirmationTokenKey]? and typeof user[@schema.confirmationTokenKey] is "string")
			return res.send 403 unless (user[@schema.confirmationTokenKey].length > 1 && confirmationToken == user[@schema.confirmationTokenKey])

			# mark as confirmed
			user[@dataKey][@schema.confirmedKey] = true

			# update user object in database
			@server.root.api.user.database.updateUserData req, res, accountID, user[@dataKey], (req, res, result) =>
				return res.send 500, 'Unable to confirm account' if not result?

				# send slack notification
				@server.root.slack.notify("[CONFIRM] User #{result[@dataKey][@emailKey]} has been confirmed :sunglasses:")

				# done
				return cb(req, res, user) if cb?
				return res.send 200
	#}}}
	confirmChange: (req, res, accountID, confirmationToken, cb) => #{{{
		@findOneByID req, res, accountID, (req, res, user) =>
			# check for errors
			return res.send 404 unless user?
			return res.send 404 unless (user[@schema.pendingEmailKey]? and typeof user[@schema.pendingEmailKey] is "string")
			return res.send 404 unless (user[@schema.pendingEmailConfirmationTokenKey]? and typeof user[@schema.pendingEmailConfirmationTokenKey] is "string")
			return res.send 403 unless (user[@schema.pendingEmailConfirmationTokenKey].length > 1 && confirmationToken == user[@schema.pendingEmailConfirmationTokenKey])

			# save old email address
			emailOld = user[@dataKey][@emailKey]

			# check again if new email isn't already in use
			@findOneByEmail req, res, user[@schema.pendingEmailKey], (req, res, resultUnused) =>

				# fail if the email they wanted is no longer available
				return res.send 409, "Email already registered for #{user?[@schema.pendingEmailKey]}" if resultUnused isnt null

				# update email address to pending change
				user[@dataKey][@emailKey] = user[@schema.pendingEmailKey]
				# mark as confirmed
				user[@dataKey][@schema.confirmedKey] = true

				# update user object in database
				@server.root.api.user.database.updateUserData req, res, accountID, user[@dataKey], (req, res, result) =>
					return res.send 500, 'Unable to confirm account' if not result?

					# get stripe customer ID from session
					stripeCustomerID = req.session?.account?.data?.stripeCustomerID
					# update stripe customer with new email address
					@server.root.stripe.customerUpdateEmail req, res, stripeCustomerID, result[@dataKey][@emailKey], (req, res) =>

						# send slack notification
						@server.root.slack.notify("[CHANGE] User email change from #{emailOld} to #{result[@dataKey][@emailKey]} has been confirmed :sunglasses:")

						# done
						return cb(req, res, user) if cb?
						return res.send 200
	#}}}

	# admin tool methods
	signupManual: (req, res) => #{{{ signup from admin tool
		# validate user data and convert to account object, send error if validation fails
		return unless recordToInsert = @schema.fromUser(req, res, req.body.insertSelect, req.body[@dataKey])

		# signup user
		return @signup(req, res, recordToInsert)
	#}}}

	# public stranger APIs
	signupTeaser: (req, res, data, cb) => #{{{ signup from teaser campaign
		# validate user data and convert to account object, send error if validation fails
		return unless recordToInsert = @schema.fromUser(req, res, 'invitation', data)

		# determine priority
		recordToInsert[@dataKey][@signupPriorityKey] = @assignSignupPriority(req)

		# signup user
		return @signup(req, res, recordToInsert, null, cb)
	#}}}
	signupTrial: (req, res, data, cb) => #{{{ signup for free trial
		# validate user data and convert to account object, send error if validation fails
		return unless recordToInsert = @schema.fromUser(req, res, 'free', data)

		# determine priority
		recordToInsert[@dataKey][@signupPriorityKey] = @assignSignupPriority(req)

		# signup user
		return @signup(req, res, recordToInsert, null, cb)
	#}}}

	upgrade: (req, res, userID, subscriptionID, args = {}, cb = null) => #{{{ if user type is free, change to premium
		@findOneByKey req, res, @docKey, userID, @projection(), (req, res, user) =>
			# sanity checks
			return cb(req, res, null) if not user and cb
			return res.send 404 if not user
			return res.send 500 if not user[@dataKey]?

			# create update object
			dataset = {}

			# upgrade user type to premium
			dataset[@typeKey] = "premium" if user[@typeKey] == "free"

			# get existing user data
			dataset[@dataKey] = user[@dataKey]

			# set new values
			dataset[@dataKey][@schema.confirmedKey] = true
			dataset[@dataKey][@schema.subscriptionCurrentIDKey] = subscriptionID
			dataset[@dataKey][@schema.stripeCustomerIDKey] = args?.stripeCustomerID if args?.stripeCustomerID
			dataset[@dataKey][@schema.amazonBillingAgreementIDKey] = args?.amazonBillingAgreementID if args?.amazonBillingAgreementID

			# update account db
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
					@server.root.slack.notify("[UPGRADE] #{result[@dataKey][@emailKey]} has been upgraded to PREMIUM :sunglasses:")

					# update user's radius db entries
					@server.root.api.radius.database.updateUserAccess req, res, result, (err) =>
						if err
							wiz.log.err(err)
							return res.send 500, 'Unable to update database'

						return cb(req, res, result) if cb
						return res.send 500 if not result2
						return res.send 200
	#}}}

# vim: foldmethod=marker wrap
