# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../resource/base'

require './password'
require './userpasswd'
#require './smartphonetotp'
#require './yubikeyhotp'
#require './skeletonkey'

wiz.package 'wiz.framework.http.acct.authenticate.module'

class wiz.framework.http.acct.authenticate.module extends wiz.framework.http.resource.base
	load: () =>
		@password = @routeAdd new wiz.framework.http.acct.authenticate.password(@server, this, 'password', 'POST')
		@userpasswd = @routeAdd new wiz.framework.http.acct.authenticate.userpasswd(@server, this, 'userpasswd', 'POST')
		#@routeAdd new wiz.framework.http.acct.authenticate.smartphonetotp(@server, this, 'smartphonetotp', 'POST')
		#@routeAdd new wiz.framework.http.acct.authenticate.yubikeyhotp(@server, this, 'yubikeyhotp', 'POST')
		#@routeAdd new wiz.framework.http.acct.authenticate.skeletonkey(@server, this, 'skeletonkey', 'POST')

# vim: foldmethod=marker wrap
