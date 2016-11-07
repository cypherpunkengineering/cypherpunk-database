# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../db/staff'

wiz.package 'cypherpunk.backend.api.staff'

class cypherpunk.backend.api.staff.resource extends cypherpunk.backend.api.base
	database: null

	load: () => #{{{
		@database = new cypherpunk.backend.db.staff(@server, this, @parent.cypherpunkDB)
		super()
		# api methods
		@routeAdd new cypherpunk.backend.api.staff.types(@server, this, 'types')
		@routeAdd new cypherpunk.backend.api.staff.list(@server, this, 'list')
		@routeAdd new cypherpunk.backend.api.staff.findAll(@server, this, 'findAll')
		@routeAdd new cypherpunk.backend.api.staff.findByType(@server, this, 'findByType')
		@routeAdd new cypherpunk.backend.api.staff.findOneByID(@server, this, 'findOneByID')
		@routeAdd new cypherpunk.backend.api.staff.insert(@server, this, 'insert', 'POST')
		@routeAdd new cypherpunk.backend.api.staff.update(@server, this, 'update', 'POST')
		@routeAdd new cypherpunk.backend.api.staff.myAccountPassword(@server, this, 'myAccountPassword', 'POST')
		@routeAdd new cypherpunk.backend.api.staff.myAccountDetails(@server, this, 'myAccountDetails', 'POST')
	#}}}

class cypherpunk.backend.api.staff.types extends cypherpunk.backend.api.base
	handler: (req, res) => #{{{
		result = {}
		result.recordTypes = JSON.parse(JSON.stringify(@parent.database.schema.types))
		res.send 200, result
	#}}}
class cypherpunk.backend.api.staff.findAll extends cypherpunk.backend.api.base
	handler: (req, res) => #{{{
		@parent.database.findAll(req, res)
	#}}}
class cypherpunk.backend.api.staff.list extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.list(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.staff.findByType extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findByType(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.staff.findOneByID extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findOneByID(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.staff.insert extends cypherpunk.backend.api.base
	# XXX: add permissions
	handler: (req, res) => #{{{
		@parent.database.insert(req, res)
	#}}}
class cypherpunk.backend.api.staff.update extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.update(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.staff.myAccountPassword extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	handler: (req, res) => #{{{
		@parent.database.myAccountPassword(req, res)
	#}}}

class cypherpunk.backend.api.staff.myAccountDetails extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	handler: (req, res) => #{{{
		@parent.database.myAccountDetails(req, res)
	#}}}

# vim: foldmethod=marker wrap
