# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../../crypto/hash'
require './base'

wiz.package 'wiz.framework.http.acct.authenticate.userpasswd'

# Example username/password authentication request:
#
# POST /account/authenticate/userpasswd
#
#	{
#		"email" : "user email"
#		"password" : "user password"
#	}
#

class wiz.framework.http.acct.authenticate.userpasswd extends wiz.framework.http.acct.authenticate.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.always
	dataKey: 'data'

	@pwHash: (plaintext) => #{{{
		hash = wiz.framework.crypto.hash.salthash(plaintext)
		return hash
	#}}}
	pwValidate: (req, res, user, plaintextPW) => #{{{
		userPW = @constructor.pwHash(plaintextPW)
		return true if user?[@dataKey].password? and userPW? and user[@dataKey].password == userPW
		return false
	#}}}

	handler: (req, res) => #{{{
		return res.send 400, 'missing parameters' unless (req.body?.login? and req.body?.password?)

		return res.send 400, 'missing or invalid login email' unless wiz.framework.util.strval.email_valid(req.body.login)
		return res.send 400, 'missing or invalid password' unless typeof req.body.password is 'string'

		return @parent.parent.db.accounts.findOneByEmail req, res, req.body.login, (req, res, user) =>
			if user?.id and @pwValidate(req, res, user, req.body.password)
				return @onAuthenticateSuccess(req, res, user)

			return res.send 400, 'user/pass authentication failed'
	#}}}

# vim: foldmethod=marker wrap
