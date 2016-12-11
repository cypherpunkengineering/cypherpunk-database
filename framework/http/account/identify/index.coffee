# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../resource/base'

require './email'

wiz.package 'wiz.framework.http.account.identify.module'

class wiz.framework.http.account.identify.module extends wiz.framework.http.resource.base
	load: () =>
		@routeAdd new wiz.framework.http.account.identify.email(@server, this, 'email', 'POST')

# vim: foldmethod=marker wrap
