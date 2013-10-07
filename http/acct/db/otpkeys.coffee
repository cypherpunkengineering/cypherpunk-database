
# copyright 2013 wiz technologies inc.

require '../../..'
require '../../../crypto/otp'
require '../../../crypto/hash'
require '../../resource/base'
require '../../db/mongo'
require '../session'

wiz.package 'wiz.framework.http.acct.db.otpkeys'

class wiz.framework.http.acct.db.otpkeys extends wiz.framework.http.database.mongo.baseArray
	collectionName: 'otp'
	docKey: 'key'
	debug: true

	otpKey: 'otp'
	otpTokenSecret32: 'secret32'
	otpTokenSecret16: 'secret16'
	otpTokenCounter10: 'counter10'
	otpTokenRequire: 'require'

	otpStatus: (req, res) => #{{{
		@findElementByID req, res, req.session.wiz.portal, req.session.wiz.user.id, (result) =>
			otp = {}
			otp = result.otp if result and result.otp
			email = ''
			email = result.email if result and result.email
			res.send 200,
				email: email
				otp: otp
	#}}}
	otpDisable: (req, res) => #{{{
		# TODO: sign all POST requests with signing key from cookie, verify signature in framework
		@otpToggle req, res, false
	#}}}
	otpToggle: (req, res, setting, cb) => #{{{
		doc = @getDocKeyWithElementID req.session.wiz.portal, req.session.wiz.user.id
		nugget = {}
		nugget["#{@otpKey}.#{@otpTokenRequire}"] = setting
		update = @getUpdateSetObj req, nugget
		options = { upsert: false }
		@updateCustom req, res, doc, update, options, cb
	#}}}
	otpIncrementCounter: (req, res, portal, id, incby = 1, cb) => #{{{
		doc = @getDocKeyWithElementID portal, id
		# {"$inc":{"users.$.otp.counter10":1}, "$set":{"users.$.updated":1337}}
		update = {}
		update["$inc"] = {}
		update["$inc"]["#{@arrayKey}.$.#{@otpKey}.#{@otpTokenCounter10}"] = incby
		options = { upsert: false }
		@updateCustom req, res, doc, update, options, cb
	#}}}
	otpEnable: (req, res) => #{{{
		@findElementByID req, res, req.session.wiz.portal, req.session.wiz.user.id, (result) =>
			if result and result.otp and result.otp.secret32

				secret = new Buffer(result.otp.secret16, 'hex')

				validationHOTP = wiz.framework.crypto.otp.validateHOTP(secret, result.otp.counter10, req.body.userotp)
				validationTOTP = wiz.framework.crypto.otp.validateTOTP(secret, req.body.userotp)

				# if matches HOTP, enable OTP and increment OTP counter
				if validationHOTP.result is true
					return @otpToggle req, res, true, (res2) =>
						return res.send 500 if res2 is null
						@otpIncrementCounter req, res, req.session.wiz.portal, req.session.wiz.user.id, validationHOTP.offset + 1

				# if matches TOTP, enable OTP
				if validationTOTP.result is true
					return @otpToggle req, res, true

			# otherwise auth fails
			res.send 400
	#}}}
	otpGenerate: (req, res) => #{{{
		# TODO: sign all POST requests with signing key from cookie, verify signature in framework
		doc = @getDocKeyWithElementID req.session.wiz.portal, req.session.wiz.user.id
		key = wiz.framework.crypto.otp.generateSecret(20)
		if not key.base32
			wiz.log.err "Unable to generate key!"
			return res.send 500
		nugget = {}
		nugget["#{@otpKey}.#{@otpTokenSecret32}"] = key.base32
		nugget["#{@otpKey}.#{@otpTokenSecret16}"] = key.hex
		nugget["#{@otpKey}.#{@otpTokenCounter10}"] = 0
		update = @getUpdateSetObj req, nugget
		options = { upsert: false }
		@updateCustom req, res, doc, update, options, () =>
			@otpToggle req, res, false
	#}}}

# vim: foldmethod=marker wrap
