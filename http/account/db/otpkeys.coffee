# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../../crypto/otp'
require '../../../crypto/hash'
require '../../resource/base'
require '../../db/mongo'
require '../session'
require './user'

wiz.package 'wiz.framework.http.account.db.otpkeys'

class wiz.framework.http.account.db.otpkeys extends wiz.framework.http.account.db.user

	arrayKey: 'otp'
	elementKey: 'key'

	otpTokenSecret32: 'secret32'
	otpTokenSecret16: 'secret16'
	otpTokenCounter10: 'counter10'
	otpTokenRequire: 'require'

	findAcctByYubiID: (req, res, keyID, cb) => #{{{ find user account from yubikey id
		authKey = null
		user = null

		# match on otp key id
		criteria = {}
		criteria["#{@arrayKey}.#{@elementKey}"] = keyID

		# get account id and matching otp key element only
		projection = {}
		projection["_id"] = 1
		projection["#{@arrayKey}.$"] = 1

		@findOne req, res, criteria, projection, (req, res, result) =>
			return cb(req, res, null, null) if not result?[@arrayKey]?[0]
			return cb(req, res, result._id, result[@arrayKey][0])
	#}}}

	otpStatus: (req, res, account, otpkeyID) => #{{{
		return res.send 500 if not account?.id? or not otpkeyID # TODO: move this to middleware

		@findElementByID req, res, account.id, otpkeyID, (result) =>
			otp = {}
			otp = result if result?.key?

			res.send 200,
				email: account.email
				otp: otp
	#}}}
	otpDisable: (req, res, account, otpkeyID) => #{{{
		return res.send 500 if not account?.id? or not otpkeyID # TODO: move this to middleware

		@otpToggle req, res, account, otpkeyID, false
	#}}}
	otpToggle: (req, res, account, otpkeyID, setting, cb) => #{{{
		return res.send 500 if not account?.id? or not otpkeyID # TODO: move this to middleware

		doc = @getDocKeyWithElementID account.id, otpkeyID
		nugget = {}
		nugget[@otpTokenRequire] = setting
		update = @getUpdateSetObj req, nugget
		options = { upsert: false }
		@updateCustom req, res, doc, update, options, cb
	#}}}
	otpIncrementCounter: (req, res, account, otpkeyID, offset, cb) => #{{{
		return res.send 500 if not account?.id? or not otpkeyID # TODO: move this to middleware

		doc = @getDocKeyWithElementID account.id, otpkeyID
		# {"$inc":{"user.$.otp.counter10":1}, "$set":{"user.$.updated":1337}}
		update = {}
		update["$inc"] = {}
		update["$inc"]["#{@arrayKey}.$.#{@otpTokenCounter10}"] = (offset + 1)
		options = { upsert: false }
		@updateCustom req, res, doc, update, options, cb
	#}}}
	otpEnable: (req, res, account, otpkeyID) => #{{{
		return res.send 500 if not account?.id? or not otpkeyID # TODO: move this to middleware

		@findElementByID req, res, account.id, otpkeyID, (result) =>
			if result?.secret16?

				# store secret in buffer for crypto methods
				secret = new Buffer(result.secret16, 'hex')

				# if matches HOTP, enable OTP and increment OTP counter
				validationHOTP = wiz.framework.crypto.otp.validateHOTP(secret, result.counter10, req.body.userotp)
				if validationHOTP.result is true
					return @otpToggle req, res, account, otpkeyID, true, (res2) =>
						return res.send 500, 'otp toggle failed' if res2 is null
						@otpIncrementCounter req, res, account, otpkeyID, validationHOTP.offset

				# if matches TOTP, enable OTP
				validationTOTP = wiz.framework.crypto.otp.validateTOTP(secret, req.body.userotp)
				if validationTOTP.result is true
					return @otpToggle req, res, account, otpkeyID, true

			# otherwise auth fails
			res.send 400, 'validation failure'
	#}}}
	otpGenerate: (req, res, account, otpkeyID) => #{{{
		doc = @getDocKeyWithElementID account.id, otpkeyID
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
			@otpToggle req, res, account, otpkeyID, false
	#}}}

# vim: foldmethod=marker wrap
