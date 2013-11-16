# copyright 2013 wiz technologies inc.

require '../../..'
require '../../../crypto/otp'
require './base'

wiz.package 'wiz.framework.http.acct.authenticate.smartphonetotp'

# Example Smartphone TOTP authentication request:
#
# POST /account/authenticate/smartphonetotp
#
#	{
#		"otp" : "smartphone otp"
#	}
#

class wiz.framework.http.acct.authenticate.smartphonetotp extends wiz.framework.http.acct.authenticate.base

	otpValidate: (req, res, user, userOTP) => #{{{
		validation = wiz.framework.crypto.otp.validateTOTP(user.secret, userOTP)
		return true if user and validation.result is true
		return res.send 400, 'otp validation failed'
	#}}}

	handler: (req, res) => #{{{
		return res.send 400, 'missing paramters' unless (req.body?.key? and req.body?.otp?)
		return res.send 400, 'invalid otp' unless wiz.framework.util.strval.hotp_valid(req.body.otp)
		return @parent.otpdb.findOneByOTPid req, res, req.body.key, (req, res, user) =>
			if otp and @otpValidate(req, res, user, req.body.otp)
				return @onIdentifySuccess(req, res, user)

			return res.send 400, 'username/password verification failed'
	#}}}

# vim: foldmethod=marker wrap
