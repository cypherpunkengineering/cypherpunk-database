# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../resource/base'

wiz.package 'wiz.framework.http.account.logout'

class wiz.framework.http.account.logout extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.public
	middleware: wiz.framework.http.account.session.base
	handler: (req, res) => #{{{
		wiz.framework.http.account.session.logout(req, res)
		res.send 200, 'OK'
	#}}}

# vim: foldmethod=marker wrap
