# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../../crypto/otp'
require './base'

wiz.package 'wiz.framework.http.acct.authenticate.skeletonkey'

# Example SkeletonKey authentication request:
#
# POST /account/authenticate/skeletonkey
#
#	{
#		"id" : "XXXX" // user-side local id to temporarily identify key object
#		"serialnum" : "XXXXXXXX....." // public key of hardware RSA keypair
#	}
#

class wiz.framework.http.acct.authenticate.skeletonkey extends wiz.framework.http.acct.authenticate.base

	handler: (req, res) => #{{{
		console.log req.body

		# fail if no keynum given
		return @fail(req, res, 'missing parameters') if not req.body?.keynum?
		# XXX TODO: fail if invalid keynum given
		#return @fail(req, res, 'invalid keynum') if not wiz.framework.util.strval.leetcode_valid(req.body.leetcode)

		# get acctID and acctOTP data for matching keyID
		keyID = req.body.keynum
		keyID = '01960755'
		@parent.parent.db.otpkeys.findAcctByYubiID req, res, keyID, (req, res, acctID, acctOTP) =>

			# fail if no matching account is found
			return @fail(req, res, 'no such acct') if not acctID or not acctOTP

			# get yubikey secret/counter from otpkeys database
			secret = new Buffer(acctOTP.secret16, 'hex')
			counter = acctOTP.counter10

			# validate given yubikey leetcode is correct
			#validation = wiz.framework.crypto.otp.validateHOTP(secret, counter, userOTP)

			# fail if validation doesnt pass
			#return @fail(req, res, 'otp incorrect') if validation.result isnt true

			# query full account object
			@parent.parent.db.accounts.findOneByID req, res, acctID, (req, res, acct) =>

				# fail if account object cant be retrieved
				return @fail(req, res, 'no such acct') if not acct

				# pass account object to success callback
				return @onAuthenticateSuccess(req, res, acct)
	#}}}

	fail: (req, res, err) => #{{{
		res.send 400, 'yubikey authentication failure', err
	#}}}
	error: (req, res, err) => #{{{
		res.send 500, 'yubikey authentication error', err
	#}}}

# vim: foldmethod=marker wrap
