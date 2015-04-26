# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../../crypto/hash'

wiz.package 'wiz.framework.database.mongo'

class wiz.framework.database.mongo.doc
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

class wiz.framework.database.mongo.docMultiType extends wiz.framework.database.mongo.doc

	@fromUser: (req, res, userType, userData, updating = false) => #{{{

		if not schemaType = @types[userType]
			err = "invalid record type: #{userType}"
		else if schemaType.creatable? and schemaType.creatable is false
			err = "record type #{userType} may not be created"
		else if not userData or typeof userData isnt 'object'
			err = "invalid post-body userData object"

		if err
			wiz.log.err(err)
			res.send(400, err)
			return false

		schemaRequired = 0
		userRequired = 0

		for field of schemaType.data

			schemaRequired += 1 if schemaType.data.required is true

			#console.log 'validating schema field ' + field

			baseError = "field #{schemaType.data[field].label} should be type #{schemaType.data[field].type}"

			if userData?[field]? # field exists

				if schemaType.data[field].type == 'int' # schema requires int type

					if wiz.framework.util.strval.validate(schemaType.data[field].type, userData[field].toString()) and # field value passes regex check
					userData[field].toString().length <= schemaType.data[field].maxlen # field value is proper length

						# convert to int
						userData[field] = parseInt(userData[field])
					else
						err = '(1)' + baseError

				else if (
					typeof userData[field] is 'string' and # field value is string
					userData[field].length <= schemaType.data[field].maxlen and # field value is proper length
					wiz.framework.util.strval.validate(schemaType.data[field].type, userData[field]) # field value passes regex check
				)

					err = null # ok

				else # invalid field value

					err = '(2)' + baseError

			else
				err = "missing required field #{field}" unless not schemaType.data.required or updating

				if schemaType.data[field].type == 'int' # convert to number
					userData[field] = parseInt(userData[field])

			if err

				wiz.log.err(err)
				res.send(400, err)
				return false

			else
				userRequired += 1 if schemaType.data.required is true # increment count and continue


		if not updating and userRequired < schemaRequired
			err = "missing required valid fields (only #{userRequired} of required #{schemaRequired} fields)"
			wiz.log.err(err)
			res.send(400, err)
			return false

		return new this(userType, userData)
	#}}}

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
