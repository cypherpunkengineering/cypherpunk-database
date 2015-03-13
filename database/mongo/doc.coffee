# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../../crypto/hash'

wiz.package 'wiz.framework.http.database.base'

class wiz.framework.http.database.base.doc
	immutable: false
	constructor: (@data) -> #{{{
		# create unique id using headers/session data as salt
		@id ?= wiz.framework.crypto.hash.digest
			payload: this
	#}}}
	initTS: () => #{{{
		# update/create timestamps
		@updated ?= wiz.framework.util.datetime.unixFullTS()
		@created ?= @updated
	#}}}
	updateTS: () => #{{{
		# update timestamp
		@updated = wiz.framework.util.datetime.unixFullTS()
	#}}}
	toDB: (req) => #{{{
		@initTS()
		return this
	#}}}
	toJSON: () => #{{{
		return this
	#}}}

class wiz.framework.http.database.base.docMultiType extends wiz.framework.http.database.base.doc

	@fromJSON: (jso) => #{{{
		if not jso.type or not jso.data or typeof jso.data is not 'array'
			wiz.log.err "invalid listing fromJSON: #{jso}"
			return null
		r = new this()
		return r
	#}}}
	constructor: (@type, @data) -> #{{{
		super(@data)
	#}}}

	toJSON: () => #{{{
		if @type and @type.type
			copy = this
			copy.type = copy.type.type
			return copy
		super()
	#}}}
	class type #{{{
		constructor: (@type, @description, @verb, @data, @creatable = true) ->
	@types: {}
	@typeValidate: () =>
		console.log 'FIX ME: @typeValidate not defined'
		return {}
	#}}}

# vim: foldmethod=marker wrap
