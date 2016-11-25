# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../../db/server'

wiz.package 'cypherpunk.backend.api.network.server'

class cypherpunk.backend.api.network.server.resource extends cypherpunk.backend.api.network.base
	database: null

	init: () => #{{{
		@database = new cypherpunk.backend.db.server(@server, this, @parent.parent.cypherpunkDB)
		# api.network methods
		@routeAdd new cypherpunk.backend.api.network.server.types(@server, this, 'types')
		@routeAdd new cypherpunk.backend.api.network.server.list(@server, this, 'list')
		@routeAdd new cypherpunk.backend.api.network.server.findAll(@server, this, 'findAll')
		@routeAdd new cypherpunk.backend.api.network.server.findByType(@server, this, 'findByType')
		@routeAdd new cypherpunk.backend.api.network.server.findOneByID(@server, this, 'findOneByID')
		@routeAdd new cypherpunk.backend.api.network.server.insert(@server, this, 'insert', 'POST')
		@routeAdd new cypherpunk.backend.api.network.server.update(@server, this, 'update', 'POST')
		super()
	#}}}

class cypherpunk.backend.api.network.server.types extends cypherpunk.backend.api.network.base
	handler: (req, res) => #{{{
		result = {}
		result.recordTypes = JSON.parse(JSON.stringify(@parent.parent.database.schema.types))
		res.send 200, result
	#}}}
class cypherpunk.backend.api.network.server.findAll extends cypherpunk.backend.api.network.base
	handler: (req, res) => #{{{
		@parent.parent.database.findAll(req, res)
	#}}}
class cypherpunk.backend.api.network.server.list extends cypherpunk.backend.api.network.base
	catchall: (req, res, routeWord) => #{{{
		@parent.parent.database.list(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.network.server.findByType extends cypherpunk.backend.api.network.base
	catchall: (req, res, routeWord) => #{{{
		@parent.parent.database.findByType(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.network.server.findOneByID extends cypherpunk.backend.api.network.base
	catchall: (req, res, routeWord) => #{{{
		@parent.parent.database.findOneByID(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.network.server.insert extends cypherpunk.backend.api.network.base
	# XXX: add permissions
	handler: (req, res) => #{{{
		@parent.parent.database.insert(req, res)
	#}}}
class cypherpunk.backend.api.network.server.update extends cypherpunk.backend.api.network.base
	catchall: (req, res, routeWord) => #{{{
		@parent.parent.database.update(req, res, routeWord)
	#}}}

# vim: foldmethod=marker wrap
