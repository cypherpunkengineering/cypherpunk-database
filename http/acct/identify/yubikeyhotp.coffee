# copyright 2013 wiz technologies inc.

require '../../..'
require '../../../crypto/otp'
require './base'

wiz.package 'wiz.framework.http.acct.identify.yubikeyhotp'

# Example YubiKey HOTP identification request:
#
# POST /account/identify/yubikeyhotp
#
#	{
#		"key" : "yubikey id"
#		"otp" : "yubikey otp"
#	}
#

class wiz.framework.http.acct.identify.yubikeyhotp extends wiz.framework.http.acct.identify.base

	otpValidate: (req, res, user, userOTP) => #{{{
		validationHOTP = wiz.framework.crypto.otp.validateHOTP(user.secret, user.counter, userOTP)
		return true if user and validation.result is true
		return res.send 400, 'otp validation failed'
	#}}}

	handler: (req, res) => #{{{
		return res.send 400, 'missing paramters' unless (req.body?.key? and req.body?.otp?)
		return res.send 400, 'invalid id' unless wiz.framework.util.strval.pengikey_valid(req.body.key)
		return res.send 400, 'invalid otp' unless wiz.framework.util.strval.hotp_valid(req.body.otp)
		return @parent.otpdb.findOneByOTPid req, res, req.body.key, (req, res, user) =>
			if otp and @otpValidate(req, res, user, req.body.otp)
				return @onIdentifySuccess(req, res, user)

			return res.send 400, 'username/password verification failed'
	#}}}

# vim: foldmethod=marker wrap
