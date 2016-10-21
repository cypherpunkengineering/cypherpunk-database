# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../../crypto/hash'
require './base'

wiz.package 'wiz.framework.http.acct.authenticate.password'

# Example username/password authentication request:
#
# POST /account/authenticate/password
#
#	{
#		"password" : "user password"
#	}
#

class wiz.framework.http.acct.authenticate.password extends wiz.framework.http.acct.authenticate.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.always
	middleware: wiz.framework.http.acct.session.base
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
		if not req.session?.id?
			return res.send 400, 'must identify first'

		if req.session?.auth? and req.session.auth != 0
			return res.send 400, 'already authenticated'

		if not req.body?.password? or typeof req.body.password != 'string'
			return res.send 400, 'missing or invalid password'

		if @pwValidate(req, res, req.session.acct, req.body.password)
			return @onAuthenticateSuccess(req, res, req.session.acct)

		return res.send 401, 'password authentication failed'
	#}}}

# vim: foldmethod=marker wrap
