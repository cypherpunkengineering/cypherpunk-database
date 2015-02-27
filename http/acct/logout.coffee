# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../resource/base'

wiz.package 'wiz.framework.http.acct.logout'

class wiz.framework.http.acct.logout extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.public
	middleware: wiz.framework.http.acct.session.base
	handler: (req, res) => #{{{
		wiz.framework.http.acct.session.logout(req, res)
		res.send 200, 'OK'
	#}}}

# vim: foldmethod=marker wrap
