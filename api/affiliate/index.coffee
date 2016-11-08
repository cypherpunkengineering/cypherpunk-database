# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../db/affiliate'

wiz.package 'cypherpunk.backend.api.affiliate'

class cypherpunk.backend.api.affiliate.resource extends cypherpunk.backend.api.base
	database: null

	init: () => #{{{
		@database = new cypherpunk.backend.db.affiliate(@server, this, @parent.cypherpunkDB)
		# api methods
		@routeAdd new cypherpunk.backend.api.affiliate.types(@server, this, 'types')
		@routeAdd new cypherpunk.backend.api.affiliate.list(@server, this, 'list')
		@routeAdd new cypherpunk.backend.api.affiliate.findAll(@server, this, 'findAll')
		@routeAdd new cypherpunk.backend.api.affiliate.findByType(@server, this, 'findByType')
		@routeAdd new cypherpunk.backend.api.affiliate.findOneByID(@server, this, 'findOneByID')
		@routeAdd new cypherpunk.backend.api.affiliate.insert(@server, this, 'insert', 'POST')
		@routeAdd new cypherpunk.backend.api.affiliate.update(@server, this, 'update', 'POST')
		@routeAdd new cypherpunk.backend.api.affiliate.myAccountPassword(@server, this, 'myAccountPassword', 'POST')
		@routeAdd new cypherpunk.backend.api.affiliate.myAccountDetails(@server, this, 'myAccountDetails', 'POST')
		super()
	#}}}

class cypherpunk.backend.api.affiliate.types extends cypherpunk.backend.api.base
	handler: (req, res) => #{{{
		result = {}
		result.recordTypes = JSON.parse(JSON.stringify(@parent.database.schema.types))
		res.send 200, result
	#}}}
class cypherpunk.backend.api.affiliate.findAll extends cypherpunk.backend.api.base
	handler: (req, res) => #{{{
		@parent.database.findAll(req, res)
	#}}}
class cypherpunk.backend.api.affiliate.list extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.list(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.affiliate.findByType extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findByType(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.affiliate.findOneByID extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findOneByID(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.affiliate.insert extends cypherpunk.backend.api.base
	# XXX: add permissions
	handler: (req, res) => #{{{
		@parent.database.insert(req, res)
	#}}}
class cypherpunk.backend.api.affiliate.update extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.update(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.affiliate.myAccountPassword extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	handler: (req, res) => #{{{
		@parent.database.myAccountPassword(req, res)
	#}}}

class cypherpunk.backend.api.affiliate.myAccountDetails extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	handler: (req, res) => #{{{
		@parent.database.myAccountDetails(req, res)
	#}}}

# vim: foldmethod=marker wrap
