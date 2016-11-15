# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../../crypto/hash'
require './base'

wiz.package 'wiz.framework.http.account.authenticate.userpasswd'

# Example username/password authentication request:
#
# POST /account/authenticate/userpasswd
#
#	{
#		"email" : "user email"
#		"password" : "user password"
#	}
#

class wiz.framework.http.account.authenticate.userpasswd extends wiz.framework.http.account.authenticate.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.always
	dataKey: 'data'
	emailKey: 'login'
	passwordKey: 'password'

	@pwHash: (plaintext) => #{{{
		hash = wiz.framework.crypto.hash.salthash(plaintext)
		return hash
	#}}}
	pwValidate: (req, res, user, plaintextPW) => #{{{
		userPW = @constructor.pwHash(plaintextPW)
		return true if user?[@dataKey]?[@passwordKey]? and userPW? and user[@dataKey][@passwordKey] == userPW
		return false
	#}}}

	handler: (req, res) => #{{{
		return res.send 400, 'missing parameters' unless (req.body?[@emailKey]? and req.body?[@passwordKey]?)

		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.email_valid(req.body[@emailKey])
		return res.send 400, 'missing or invalid password' unless typeof req.body[@passwordKey] is 'string'

		return @parent.parent.database.findOneByEmail req, res, req.body[@emailKey], (req, res, user) =>
			if user?.id and @pwValidate(req, res, user, req.body[@passwordKey])
				return @onAuthenticateSuccess(req, res, user)

			return res.send 400, 'user/pass authentication failed'
	#}}}

# vim: foldmethod=marker wrap
