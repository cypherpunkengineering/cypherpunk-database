# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../db/refund'

wiz.package 'cypherpunk.backend.api.refund'

class cypherpunk.backend.api.refund.resource extends cypherpunk.backend.api.base
	database: null

	init: () => #{{{
		@database = new cypherpunk.backend.db.refund(@server, this, @parent.cypherpunkDB)
		# api methods
		@routeAdd new cypherpunk.backend.api.refund.types(@server, this, 'types')
		@routeAdd new cypherpunk.backend.api.refund.list(@server, this, 'list')
		@routeAdd new cypherpunk.backend.api.refund.findAll(@server, this, 'findAll')
		@routeAdd new cypherpunk.backend.api.refund.findByType(@server, this, 'findByType')
		@routeAdd new cypherpunk.backend.api.refund.findOneByID(@server, this, 'findOneByID')
		super()
	#}}}

class cypherpunk.backend.api.refund.types extends cypherpunk.backend.api.base
	handler: (req, res) => #{{{
		result = {}
		result.recordTypes = JSON.parse(JSON.stringify(@parent.database.schema.types))
		res.send 200, result
	#}}}
class cypherpunk.backend.api.refund.findAll extends cypherpunk.backend.api.base
	handler: (req, res) => #{{{
		@parent.database.findAll(req, res)
	#}}}
class cypherpunk.backend.api.refund.list extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.list(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.refund.findByType extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findByType(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.refund.findOneByID extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findOneByID(req, res, routeWord)
	#}}}

# vim: foldmethod=marker wrap
