# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../db/user'

wiz.package 'cypherpunk.backend.api.user'

class cypherpunk.backend.api.user.resource extends cypherpunk.backend.api.base
	database: null

	init: () => #{{{
		@database = new cypherpunk.backend.db.user(@server, this, @parent.cypherpunkDB)
		# api methods
		@routeAdd new cypherpunk.backend.api.user.types(@server, this, 'types')
		@routeAdd new cypherpunk.backend.api.user.list(@server, this, 'list')
		@routeAdd new cypherpunk.backend.api.user.findAll(@server, this, 'findAll')
		@routeAdd new cypherpunk.backend.api.user.findByType(@server, this, 'findByType')
		@routeAdd new cypherpunk.backend.api.user.findOneByID(@server, this, 'findOneByID')
		@routeAdd new cypherpunk.backend.api.user.insertUniqueEmail(@server, this, 'insert', 'POST')
		@routeAdd new cypherpunk.backend.api.user.update(@server, this, 'update', 'POST')
		@routeAdd new cypherpunk.backend.api.user.myAccountPassword(@server, this, 'myAccountPassword', 'POST')
		@routeAdd new cypherpunk.backend.api.user.myAccountDetails(@server, this, 'myAccountDetails', 'POST')
		super()
	#}}}

class cypherpunk.backend.api.user.types extends cypherpunk.backend.api.base
	handler: (req, res) => #{{{
		result = {}
		result.recordTypes = JSON.parse(JSON.stringify(@parent.database.schema.types))
		res.send 200, result
	#}}}
class cypherpunk.backend.api.user.findAll extends cypherpunk.backend.api.base
	handler: (req, res) => #{{{
		@parent.database.findAll(req, res)
	#}}}
class cypherpunk.backend.api.user.list extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.list(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.user.findByType extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findByType(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.user.findOneByID extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findOneByID(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.user.insertUniqueEmail extends cypherpunk.backend.api.base
	# XXX: add permissions
	handler: (req, res) => #{{{
		@parent.database.insertUniqueEmail(req, res)
	#}}}
class cypherpunk.backend.api.user.update extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.update(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.user.myAccountPassword extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	handler: (req, res) => #{{{
		@parent.database.myAccountPassword(req, res)
	#}}}

class cypherpunk.backend.api.user.myAccountDetails extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	handler: (req, res) => #{{{
		@parent.database.myAccountDetails(req, res)
	#}}}

# vim: foldmethod=marker wrap
