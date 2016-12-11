# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../db/admin'

wiz.package 'cypherpunk.backend.api.admin'

class cypherpunk.backend.api.admin.resource extends cypherpunk.backend.api.base
	database: null

	load: () => #{{{
		@database = new cypherpunk.backend.db.admin(@server, this, @parent.cypherpunkDB)
		super()
		# api methods
		@routeAdd new cypherpunk.backend.api.admin.types(@server, this, 'types')
		@routeAdd new cypherpunk.backend.api.admin.list(@server, this, 'list')
		@routeAdd new cypherpunk.backend.api.admin.findAll(@server, this, 'findAll')
		@routeAdd new cypherpunk.backend.api.admin.findByType(@server, this, 'findByType')
		@routeAdd new cypherpunk.backend.api.admin.findOneByID(@server, this, 'findOneByID')
		@routeAdd new cypherpunk.backend.api.admin.insert(@server, this, 'insert', 'POST')
		@routeAdd new cypherpunk.backend.api.admin.update(@server, this, 'update', 'POST')
		@routeAdd new cypherpunk.backend.api.admin.myAccountPassword(@server, this, 'myAccountPassword', 'POST')
		@routeAdd new cypherpunk.backend.api.admin.myAccountDetails(@server, this, 'myAccountDetails', 'POST')
	#}}}

class cypherpunk.backend.api.admin.types extends cypherpunk.backend.api.base
	handler: (req, res) => #{{{
		result = {}
		result.recordTypes = JSON.parse(JSON.stringify(@parent.database.schema.types))
		res.send 200, result
	#}}}
class cypherpunk.backend.api.admin.findAll extends cypherpunk.backend.api.base
	handler: (req, res) => #{{{
		@parent.database.findAll(req, res)
	#}}}
class cypherpunk.backend.api.admin.list extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.list(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.admin.findByType extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findByType(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.admin.findOneByID extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findOneByID(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.admin.insert extends cypherpunk.backend.api.base
	# XXX: add permissions
	handler: (req, res) => #{{{
		@parent.database.insert(req, res)
	#}}}
class cypherpunk.backend.api.admin.update extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.update(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.admin.myAccountPassword extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	handler: (req, res) => #{{{
		@parent.database.myAccountPassword(req, res)
	#}}}

class cypherpunk.backend.api.admin.myAccountDetails extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	handler: (req, res) => #{{{
		@parent.database.myAccountDetails(req, res)
	#}}}

# vim: foldmethod=marker wrap
