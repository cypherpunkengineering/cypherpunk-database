# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../db/smartdns'

wiz.package 'cypherpunk.backend.api.smartdns'

class cypherpunk.backend.api.smartdns.resource extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.always
	database: null
	config:
		hostname: ''
		username: ''
		password: ''
		database: ''

	init: () => #{{{
		@database = new cypherpunk.backend.db.smartdns(@server, this, @config)
		@routeAdd new cypherpunk.backend.api.smartdns.serverInsert(@server, this, 'serverInsert', 'POST')
		super()
	#}}}

class cypherpunk.backend.api.smartdns.serverInsert extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.always
	handler: (req, res) => #{{{
		return res.send 403 if req?.body?.token != "secretapikey9@"
		@parent.database.serverInsert req, res, req?.body?.server, req?.body?.ipaddress, (req, res, err) =>
			return res.send 400, err if err?
			return res.send 200
	#}}}

# vim: foldmethod=marker wrap
