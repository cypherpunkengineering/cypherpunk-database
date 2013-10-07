# copyright 2013 wiz technologies inc.

require '../../..'
require '../../resource/base'

wiz.package 'wiz.framework.http.acct.authenticate.module'

class wiz.framework.http.acct.authenticate.module extends wiz.framework.http.resource.base
	init: () =>
		#@routeAdd new wiz.framework.http.acct.authenticate.yubikeyhotp(@server, this, 'yubikeyhotp', 'POST')

		super()

# vim: foldmethod=marker wrap
