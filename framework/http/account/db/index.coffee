# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require './user'
require './admin'
require './otpkeys'

wiz.package 'wiz.framework.http.account.db.module'

class wiz.framework.http.account.db.module
	init: () =>
		super()

# vim: foldmethod=marker wrap
