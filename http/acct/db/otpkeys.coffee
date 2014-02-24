# copyright 2013 wiz technologies inc.

require '../../..'
require '../../../crypto/otp'
require '../../../crypto/hash'
require '../../resource/base'
require '../../db/mongo'
require '../session'
require './accounts'

wiz.package 'wiz.framework.http.acct.db.otpkeys'

class wiz.framework.http.acct.db.otpkeys extends wiz.framework.http.acct.db.accounts

	arrayKey: 'otp'
	elementKey: 'key'

	otpTokenSecret32: 'secret32'
	otpTokenSecret16: 'secret16'
	otpTokenCounter10: 'counter10'
	otpTokenRequire: 'require'

	findAcctByYubiID: (req, res, keyID, cb) => #{{{ find user acct from yubikey id
		authKey = null
		user = null

		# match on otp key id
		query = {}
		query["#{@arrayKey}.#{@elementKey}"] = keyID

		# get account id and matching otp key element only
		select = {}
		select["_id"] = 1
		select["#{@arrayKey}.$"] = 1

		@findOne req, res, query, select, (req, res, result) =>
			return cb(req, res, null, null) if not result?[@arrayKey]?[0]
			return cb(req, res, result._id, result[@arrayKey][0])
	#}}}

	otpStatus: (req, res, acct, otpkeyID) => #{{{
		return res.send 500 if not acct?.id? or not otpkeyID # TODO: move this to middleware

		@findElementByID req, res, acct.id, otpkeyID, (result) =>
			otp = {}
			otp = result if result?.key?

			res.send 200,
				email: acct.email
				otp: otp
	#}}}
	otpDisable: (req, res, acct, otpkeyID) => #{{{
		return res.send 500 if not acct?.id? or not otpkeyID # TODO: move this to middleware

		@otpToggle req, res, acct, otpkeyID, false
	#}}}
	otpToggle: (req, res, acct, otpkeyID, setting, cb) => #{{{
		return res.send 500 if not acct?.id? or not otpkeyID # TODO: move this to middleware

		doc = @getDocKeyWithElementID acct.id, otpkeyID
		nugget = {}
		nugget[@otpTokenRequire] = setting
		update = @getUpdateSetObj req, nugget
		options = { upsert: false }
		@updateCustom req, res, doc, update, options, cb
	#}}}
	otpIncrementCounter: (req, res, acct, otpkeyID, offset, cb) => #{{{
		return res.send 500 if not acct?.id? or not otpkeyID # TODO: move this to middleware

		doc = @getDocKeyWithElementID acct.id, otpkeyID
		# {"$inc":{"users.$.otp.counter10":1}, "$set":{"users.$.updated":1337}}
		update = {}
		update["$inc"] = {}
		update["$inc"]["#{@arrayKey}.$.#{@otpTokenCounter10}"] = (offset + 1)
		options = { upsert: false }
		@updateCustom req, res, doc, update, options, cb
	#}}}
	otpEnable: (req, res, acct, otpkeyID) => #{{{
		return res.send 500 if not acct?.id? or not otpkeyID # TODO: move this to middleware

		@findElementByID req, res, acct.id, otpkeyID, (result) =>
			if result?.secret16?

				# store secret in buffer for crypto methods
				secret = new Buffer(result.secret16, 'hex')

				# if matches HOTP, enable OTP and increment OTP counter
				validationHOTP = wiz.framework.crypto.otp.validateHOTP(secret, result.counter10, req.body.userotp)
				if validationHOTP.result is true
					return @otpToggle req, res, acct, otpkeyID, true, (res2) =>
						return res.send 500, 'otp toggle failed' if res2 is null
						@otpIncrementCounter req, res, acct, otpkeyID, validationHOTP.offset

				# if matches TOTP, enable OTP
				validationTOTP = wiz.framework.crypto.otp.validateTOTP(secret, req.body.userotp)
				if validationTOTP.result is true
					return @otpToggle req, res, acct, otpkeyID, true

			# otherwise auth fails
			res.send 400, 'validation failure'
	#}}}
	otpGenerate: (req, res, acct, otpkeyID) => #{{{
		doc = @getDocKeyWithElementID acct.id, otpkeyID
		key = wiz.framework.crypto.otp.generateSecret(20)
		if not key.base32
			wiz.log.err "Unable to generate key!"
			return res.send 500
		nugget = {}
		nugget[@otpTokenSecret32] = key.base32
		nugget[@otpTokenSecret16] = key.hex
		nugget[@otpTokenCounter10] = 0
		update = @getUpdateSetObj req, nugget
		options = { upsert: false }
		@updateCustom req, res, doc, update, options, () =>
			@otpToggle req, res, acct, otpkeyID, false
	#}}}

# vim: foldmethod=marker wrap
