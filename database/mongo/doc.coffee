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

		err = null

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

			wiz.log.debug 'validating schema field ' + field

			errorIncorrectType = "field #{schemaType.data[field].label} must be type #{schemaType.data[field].type}"
			errorTooLong = "field #{schemaType.data[field].label} is too long, cannot be more than #{schemaType.data[field].maxlen} characters."
			errorTooMany = "field #{schemaType.data[field].label} cannot contain more than #{schemaType.data[field].maxElements} selections."

			if userData?[field]? # field exists

				if schemaType.data[field].type == 'int' # schema requires int type

					if not wiz.framework.util.strval.validate(schemaType.data[field].type, userData[field].toString()) # field value passes regex check

						err = '(11)' + errorIncorrectType

					else if userData[field].toString().length > schemaType.data[field].maxlen # field value is proper length

						err = '(12)' + errorTooLong

					else
						# convert to int
						userData[field] = parseInt(userData[field])

				else if schemaType.data[field].type == 'array' # schema requires array

					# convert to array with one element if necessary
					if userData[field] not instanceof Array
						userData[field] = [ userData[field] ]

					# validate max element count
					if userData[field].length > (schemaType.data[field].maxElements or 0)

						console.log userData[field]
						console.log userData[field].length
						err = '(32)' + errorTooMany

					# validate each element value and maxlen
					for element of userData[field]

						if not wiz.framework.util.strval.validate(schemaType.data[field].arrayType, element)

							err = '(33)' + errorIncorrectType + ' ' + element

						else if element.length > (schemaType.data[field].maxlen or 0)

							err = '(34)' + errorTooLong

				else if typeof userData[field] is 'string' # field value is string

					if not wiz.framework.util.strval.validate(schemaType.data[field].type, userData[field]) # field value passes regex check

						err = '(21)' + errorIncorrectType

					else if userData[field].length > schemaType.data[field].maxlen # field value is proper length

						err = '(22)' + errorTooLong

				else if schemaType.data[field].type == 'boolean' # true or false

					if userData[field] != 'on' and userData[field] != 'off'

						err = '(41)' + errorIncorrectType + ' ' + element

				else # invalid field value

					err = '(9)' + errorIncorrectType

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
