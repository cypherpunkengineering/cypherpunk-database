# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../../crypto/hash'
require './base'

wiz.package 'wiz.framework.http.acct.identify.email'

# Example email identification request:
#
# POST /account/identify/email
#
#	{
#		"email" : "user email"
#	}
#

class wiz.framework.http.acct.identify.email extends wiz.framework.http.acct.identify.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.always
	dataKey: 'data'

	handler: (req, res) => #{{{
		return res.send 400, 'missing parameters' unless req.body?.email?
		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.email_valid(req.body.email)

		return @parent.parent.db.accounts.findOneByEmail req, res, req.body.email, (req, res, user) =>
			return @onIdentifySuccess(req, res, user) if user?.id?
			return res.send 401, 'email identification failed'
	#}}}

# vim: foldmethod=marker wrap
