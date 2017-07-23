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
		@routeAdd new cypherpunk.backend.api.user.signupManual(@server, this, 'insert', 'POST')
		@routeAdd new cypherpunk.backend.api.user.grantInvitation(@server, this, 'grantInvitation', 'POST')
		@routeAdd new cypherpunk.backend.api.user.update(@server, this, 'update', 'POST')
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
class cypherpunk.backend.api.user.signupManual extends cypherpunk.backend.api.base
	# XXX: add permissions
	handler: (req, res) => #{{{
		@parent.database.signupManual(req, res)
	#}}}
class cypherpunk.backend.api.user.grantInvitation extends cypherpunk.backend.api.base
	# XXX: add permissions
	handler: (req, res) => #{{{
		return res.send 400, 'missing email' unless req.body?.email?
		@parent.database.grantInvitation(req, res, req.body.email)
	#}}}
class cypherpunk.backend.api.user.update extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.update(req, res, routeWord)
	#}}}

# vim: foldmethod=marker wrap
