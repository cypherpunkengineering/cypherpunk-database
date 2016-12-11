# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

wiz.package 'cypherpunk.backend.api.network'

class cypherpunk.backend.api.network.base extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.engineer

require './location'
require './server'

class cypherpunk.backend.api.network.module extends cypherpunk.backend.api.network.base
	load: () =>
		@location = @routeAdd new cypherpunk.backend.api.network.location.resource(@server, this, 'location')
		@server = @routeAdd new cypherpunk.backend.api.network.server.resource(@server, this, 'server')

# vim: foldmethod=marker wrap
