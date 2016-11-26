# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../resource/base'

wiz.package 'wiz.framework.http.account.status'

class wiz.framework.http.account.status extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.friend
	mask: wiz.framework.http.resource.power.mask.auth
	middleware: wiz.framework.http.account.session.refresh
	handler: (req, res) => #{{{
		out = @parent.accountinfo(req)
		res.send 200, out
	#}}}

# vim: foldmethod=marker wrap
