
require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

wiz.package 'cypherpunk.backend.api.v0.monitoring'

class cypherpunk.backend.api.v0.monitoring.module extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	load: () =>
		super()

		@routeAdd new cypherpunk.backend.api.v0.monitoring.hello(@server, this, 'hello')

class cypherpunk.backend.api.v0.monitoring.hello extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	handler: (req, res) =>
		req.server.root.api.user.database.count req, res, {}, {}, (req, res, count) =>
			wiz.log.info "Current DB user count: #{count}"
			res.send 200, "hi mike"

# vim: foldmethod=marker wrap
