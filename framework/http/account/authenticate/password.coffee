# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../../crypto/hash'
require './base'

wiz.package 'wiz.framework.http.account.authenticate.password'

# Example username/password authentication request:
#
# POST /account/authenticate/password
#
#	{
#		"password" : "user password"
#	}
#

class wiz.framework.http.account.authenticate.password extends wiz.framework.http.account.authenticate.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.always
	middleware: wiz.framework.http.account.session.base
	dataKey: 'data'
	passwordKey: 'password'

	@pwHash: (plaintext) => #{{{
		hash = wiz.framework.crypto.hash.salthash(plaintext)
		return hash
	#}}}
	pwValidate: (req, res, user, plaintextPW) => #{{{
		userPW = @constructor.pwHash(plaintextPW)
		#console.log userPW
		#console.log user
		return true if user?[@dataKey]?[@passwordKey]? and userPW? and user[@dataKey][@passwordKey] == userPW
		return false
	#}}}

	handler: (req, res) => #{{{
		if not req.session?.id?
			return res.send 400, 'must identify first'

		if not req.body?[@passwordKey]? or typeof req.body[@passwordKey] != 'string'
			return res.send 400, 'missing or invalid password'

		if @pwValidate(req, res, req.session.account, req.body[@passwordKey])
			return @parent.parent.onAuthenticateSuccess(req, res, req.session.account)

		return res.send 401, 'password authentication failed'
	#}}}

# vim: foldmethod=marker wrap
