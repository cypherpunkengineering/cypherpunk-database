# copyright 2013 wiz technologies inc.

require '../..'

wiz.package 'wiz.framework.http.resource.power'

class wiz.framework.http.resource.power.level
	@unknown: 0
	@stranger: 1
	@friend: 1001

class wiz.framework.http.resource.power.mask
	@unknown: 0
	@always: 1
	@public: 2
	@auth: 3

# vim: foldmethod=marker wrap
