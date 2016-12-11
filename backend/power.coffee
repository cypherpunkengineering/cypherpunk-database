# wizportal web interface
# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/power'

wiz.package 'cypherpunk.backend.server.power'

class cypherpunk.backend.server.power.mask extends wiz.framework.http.resource.power.mask
	@mailgw: 4
	@domain: 5

class cypherpunk.backend.server.power.level extends wiz.framework.http.resource.power.level

	#################### CUSTOMERS

	# customer
	@free: 2100
	@premium: 2200
	@family: 2300
	@enterprise: 2500

	##################### AFFILIATES

	# affiliate
	@affiliate: 3100

	##################### STAFF USER

	# staff user accounts
	@staff: 5100

	# engineer user account
	@developer: 7100

	##################### STAFF ADMIN

	# staff admin accounts
	@support: 8100
	@marketing: 8200
	@legal: 8300
	@executive: 8500

	# engineer admin accounts
	@engineer: 9001
	@wiz: 9999

# vim: foldmethod=marker wrap

