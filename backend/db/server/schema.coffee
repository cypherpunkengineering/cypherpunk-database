# copyright 2012 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/database/mongo/doc'
require './_framework/util/strval'
require './_framework/util/datetime'
require './_framework/http/account/authenticate/userpasswd'

wiz.package 'cypherpunk.backend.db.server.schema'

class type
	constructor: (@type, @description, @verb, @data, @creatable = true) ->

class cypherpunk.backend.db.server.schema extends wiz.framework.database.mongo.docMultiType

	class type #{{{
		constructor: (@type, @description, @verb, @data, @creatable = true) ->
	@types:
	#}}}
		server: (new type 'server', 'Privacy Server', 'list', #{{{
			id:
				label: 'server id'
				placeholder: 'tokyo1'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			region:
				label: ''
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}

# vim: foldmethod=marker wrap
