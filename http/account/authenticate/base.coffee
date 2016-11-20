# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../resource/base'
require '../session'

wiz.package 'wiz.framework.http.account.authenticate.base'

class wiz.framework.http.account.authenticate.base extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.always

# vim: foldmethod=marker wrap
