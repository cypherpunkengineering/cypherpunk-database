require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require './add'
require './default'
require './list'

wiz.package 'cypherpunk.backend.api.v0.account.source'

class cypherpunk.backend.api.v0.account.source.resource extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	load: () =>
		# inherit
		super()

		# public account creation api
		@routeAdd new cypherpunk.backend.api.v0.account.source.add(@server, this, 'add', 'POST')
		@routeAdd new cypherpunk.backend.api.v0.account.source.default(@server, this, 'default', 'POST')
		@routeAdd new cypherpunk.backend.api.v0.account.source.list(@server, this, 'list')

# vim: foldmethod=marker wrap
