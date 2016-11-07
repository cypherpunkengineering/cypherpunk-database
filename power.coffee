# wizportal web interface
# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/power'

wiz.package 'cypherpunk.backend.server.power'

class cypherpunk.backend.server.power.mask extends wiz.framework.http.resource.power.mask
	@mailgw: 4
	@domain: 5

class cypherpunk.backend.server.power.level extends wiz.framework.http.resource.power.level
	@customerFree: 2001
	@customerPremium: 3001
	@affiliate: 4001
	@support: 6001
	@admin: 7001
	@developer: 8001
	@wiz: 9001

# vim: foldmethod=marker wrap

