# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../../crypto/hash'

wiz.package 'wiz.framework.http.database.base'

class wiz.framework.http.database.base.doc
	immutable: false
	constructor: () -> #{{{
		# create unique id using headers/session data as salt
		@id ?= wiz.framework.crypto.hash.digest
			payload: this
			headers: req.headers
			session: req.session
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
	docType: wiz.framework.http.database.base.docMultiType

	@fromUser: (req, res, type, data) => #{{{
		# check listing
		return if not t = @typeValidate(req, res, type)

		if t.creatable? and t.creatable is false
			wiz.log.err "record type #{type} may not be created"
			res.send 400
			return false

		validated = 0
		if data and typeof data is 'object' then for arg, i in t.data
			if data[i] and
			typeof data[i] is 'string' and
			data[i].length <= t.data[i].maxlen and
			wiz.framework.util.strval.validate(t.data[i].type, data[i])

				validated += 1

		if validated != t.data.length
			wiz.log.err "valid arguments #{validated} (of required #{t.data.length}): #{data}"
			res.send 400
			return false

		return new @docType(type, data)
	#}}}
	@fromJSON: (jso) => #{{{
		if not jso.type or not jso.data or typeof jso.data is not 'array'
			wiz.log.err "invalid listing fromJSON: #{jso}"
			return null
		r = new @docType()
		return r
	#}}}
	toJSON: () => #{{{
		if @type and @type.type
			copy = this
			copy.type = copy.type.type
			return copy
		super()
	#}}}

	@typeValidate: (req, res, type) => #{{{
		return type if type = @types[type]
		wiz.log.err "invalid listing type: #{@type}"
		res.send 400
		return null
	#}}}
	class type #{{{
		constructor: (@type, @description, @verb, @data, @creatable = true) ->
	#}}}
	@types: {} # define in child class

# vim: foldmethod=marker wrap
