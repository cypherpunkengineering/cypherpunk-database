# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../db/radius'

wiz.package 'cypherpunk.backend.api.radius'

class cypherpunk.backend.api.radius.resource extends cypherpunk.backend.api.base
	database: null
	config:
		hostname: ''
		username: ''
		password: ''
		database: ''

	init: () => #{{{
		@database = new cypherpunk.backend.db.radius(@server, this, @config)
		super()
	#}}}

# vim: foldmethod=marker wrap
