# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../db/charge'

wiz.package 'cypherpunk.backend.api.charge'

class cypherpunk.backend.api.charge.resource extends cypherpunk.backend.api.base
	database: null

	init: () => #{{{
		@database = new cypherpunk.backend.db.charge(@server, this, @parent.cypherpunkDB)
		# api methods
		@routeAdd new cypherpunk.backend.api.charge.types(@server, this, 'types')
		@routeAdd new cypherpunk.backend.api.charge.list(@server, this, 'list')
		@routeAdd new cypherpunk.backend.api.charge.findAll(@server, this, 'findAll')
		@routeAdd new cypherpunk.backend.api.charge.findByType(@server, this, 'findByType')
		@routeAdd new cypherpunk.backend.api.charge.findOneByID(@server, this, 'findOneByID')
		super()
	#}}}

class cypherpunk.backend.api.charge.types extends cypherpunk.backend.api.base
	handler: (req, res) => #{{{
		result = {}
		result.recordTypes = JSON.parse(JSON.stringify(@parent.database.schema.types))
		res.send 200, result
	#}}}
class cypherpunk.backend.api.charge.findAll extends cypherpunk.backend.api.base
	handler: (req, res) => #{{{
		@parent.database.findAll(req, res)
	#}}}
class cypherpunk.backend.api.charge.list extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.list(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.charge.findByType extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findByType(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.charge.findOneByID extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findOneByID(req, res, routeWord)
	#}}}

# vim: foldmethod=marker wrap
