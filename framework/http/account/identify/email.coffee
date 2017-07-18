# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../../crypto/hash'
require './base'

wiz.package 'wiz.framework.http.account.identify.email'

# Example email identification request:
#
# POST /account/identify/email
#
#	{
#		"email" : "user email"
#	}
#

class wiz.framework.http.account.identify.email extends wiz.framework.http.account.identify.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.always
	dataKey: 'data'
	emailKey: 'email'

	handler: (req, res) => #{{{
		return res.send 400, 'missing parameters' unless req.body?[@emailKey]?
		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.email_valid(req.body[@emailKey])

		return @parent.parent.database.findOneByEmail req, res, req.body[@emailKey], (req, res, user) =>
			return res.send 402 if user?.type is 'invitation' or user?.type is 'pending'
			return @onIdentifySuccess(req, res, user) if user?.id?
			return res.send 401
	#}}}

# vim: foldmethod=marker wrap
