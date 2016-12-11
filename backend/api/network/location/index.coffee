# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../../db/location'

wiz.package 'cypherpunk.backend.api.network.location'

class cypherpunk.backend.api.network.location.resource extends cypherpunk.backend.api.network.base
	database: null

	init: () => #{{{
		@database = new cypherpunk.backend.db.location(@server, this, @parent.parent.cypherpunkDB)
		# api.network methods
		@routeAdd new cypherpunk.backend.api.network.location.types(@server, this, 'types')
		@routeAdd new cypherpunk.backend.api.network.location.list(@server, this, 'list')
		@routeAdd new cypherpunk.backend.api.network.location.findAll(@server, this, 'findAll')
		@routeAdd new cypherpunk.backend.api.network.location.findByType(@server, this, 'findByType')
		@routeAdd new cypherpunk.backend.api.network.location.findOneByID(@server, this, 'findOneByID')
		@routeAdd new cypherpunk.backend.api.network.location.insert(@server, this, 'insert', 'POST')
		@routeAdd new cypherpunk.backend.api.network.location.update(@server, this, 'update', 'POST')
		super()
	#}}}

class cypherpunk.backend.api.network.location.types extends cypherpunk.backend.api.network.base
	handler: (req, res) => #{{{
		result = {}
		result.recordTypes = JSON.parse(JSON.stringify(@parent.database.schema.types))
		res.send 200, result
	#}}}
class cypherpunk.backend.api.network.location.findAll extends cypherpunk.backend.api.network.base
	handler: (req, res) => #{{{
		@parent.database.findAll(req, res)
	#}}}
class cypherpunk.backend.api.network.location.list extends cypherpunk.backend.api.network.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.list(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.network.location.findByType extends cypherpunk.backend.api.network.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findByType(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.network.location.findOneByID extends cypherpunk.backend.api.network.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findOneByID(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.network.location.insert extends cypherpunk.backend.api.network.base
	# XXX: add permissions
	handler: (req, res) => #{{{
		@parent.database.insert(req, res)
	#}}}
class cypherpunk.backend.api.network.location.update extends cypherpunk.backend.api.network.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.update(req, res, routeWord)
	#}}}

# vim: foldmethod=marker wrap
