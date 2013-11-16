# copyright 2013 wiz technologies inc.

require '../../..'
require '../../resource/base'

require './smartphonetotp'

wiz.package 'wiz.framework.http.acct.authenticate.module'

class wiz.framework.http.acct.authenticate.module extends wiz.framework.http.resource.base
	load: () =>
		@routeAdd new wiz.framework.http.acct.authenticate.smartphonetotp(@server, this, 'smartphonetotp', 'POST')

# vim: foldmethod=marker wrap
