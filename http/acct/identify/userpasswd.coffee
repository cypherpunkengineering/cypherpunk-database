# copyright 2013 wiz technologies inc.

require '../../..'
require '../../../crypto/hash'
require './base'

wiz.package 'wiz.framework.http.acct.identify.userpasswd'

# Example username/password identification request:
#
# POST /account/identify/userpasswd
#
#	{
#		"email" : "user email"
#		"password" : "user password"
#	}
#

class wiz.framework.http.acct.identify.userpasswd extends wiz.framework.http.acct.identify.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.always

	pwHash: (plaintext) => #{{{
		hash = wiz.framework.crypto.hash.salthash(plaintext)
		return hash
	#}}}
	pwValidate: (req, res, user, plaintextPW) => #{{{
		userPW = @pwHash(plaintextPW)
		return true if user?.pw? and userPW? and user.pw == userPW
		return false
	#}}}

	handler: (req, res) => #{{{
		return res.send 400, 'missing parameters' unless (req.body?.login? and req.body?.password?)

		return res.send 400, 'missing or invalid login email' unless wiz.framework.util.strval.email_valid(req.body.login)
		return res.send 400, 'missing or invalid password' unless typeof req.body.password is 'string'

		return @parent.parent.db.accounts.findOneByEmail req, res, req.body.login, (req, res, user) =>
			if user?.id and @pwValidate(req, res, user, req.body.password)
				return @onIdentifySuccess(req, res, user)

			return res.send 400, 'username/password verification failed'
	#}}}

# vim: foldmethod=marker wrap
