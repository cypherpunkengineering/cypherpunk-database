# copyright 2013 wiz technologies inc.

require '../../..'
require '../../resource/base'

require './userpasswd'
require './yubikeyhotp'

wiz.package 'wiz.framework.http.acct.identify.module'

class wiz.framework.http.acct.identify.module extends wiz.framework.http.resource.base
	init: () =>
		@routeAdd new wiz.framework.http.acct.identify.userpasswd(@server, this, 'userpasswd', 'POST')
		@routeAdd new wiz.framework.http.acct.identify.yubikeyhotp(@server, this, 'yubikeyhotp', 'POST')

		super()

# vim: foldmethod=marker wrap
