# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../../crypto/hash'

wiz.package 'wiz.framework.database.mongo'

class wiz.framework.database.mongo.doc
	immutable: false
	constructor: (@data = {}) -> #{{{
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
	@docKey: 'id'
	@dataKey: 'data'

	@fromUser: (req, res, userType, userData, updating = false) => #{{{

		err = null
		outputData = {}

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
			errorTooShort = "field #{schemaType.data[field].label} is too short, cannot be less than #{schemaType.data[field].minlen} characters."
			errorTooLong = "field #{schemaType.data[field].label} is too long, cannot be more than #{schemaType.data[field].maxlen} characters."
			errorTooMany = "field #{schemaType.data[field].label} cannot contain more than #{schemaType.data[field].maxElements} selections."

			if userData?[field]? # field exists

				userRequired += 1 if schemaType.data.required is true

				if schemaType.data[field].type == 'int' #{{{ schema requires int type

					if not wiz.framework.util.strval.validate(schemaType.data[field].type, userData[field].toString()) # field value passes regex check

						err = '(11)' + errorIncorrectType

					else if userData[field].toString().length < (schemaType.data[field].minlen or 0) # field value is proper length

						err = '(12)' + errorTooShort

					else if userData[field].toString().length > (schemaType.data[field].maxlen or 99999) # field value is proper length

						err = '(13)' + errorTooLong

					else
						# convert to int and store in output
						outputData[field] = parseInt(userData[field])
				#}}}
				else if schemaType.data[field].type == 'array' #{{{ schema requires array

					# create destination array
					outputData[field] = []

					# convert userData field to array with one element if necessary
					if userData[field] not instanceof Array
						userData[field] = [ userData[field] ]

					# validate max element count
					if userData[field].length > (schemaType.data[field].maxElements or 0)

						err = '(32)' + errorTooMany

					# validate each element value and maxlen
					for element of userData[field]

						if not wiz.framework.util.strval.validate(schemaType.data[field].arrayType, element)

							err = '(33)' + errorIncorrectType + ' ' + element

						else if element.length < (schemaType.data[field].minlen or 0)

							err = '(34)' + errorTooShort

						else if element.length > (schemaType.data[field].maxlen or 99999)

							err = '(35)' + errorTooLong

						else
							# store in output
							outputData[field] = userData[field]
				#}}}
				else if schemaType.data[field].type == 'boolean' #{{{ true or false

					if userData[field] != 'true' and userData[field] != 'false'

						err = '(41)' + errorIncorrectType + ' ' + userData[field]

					else
						# store in output
						outputData[field] = userData[field]

				#}}}
				else if typeof userData[field] == 'string' #{{{ field value is string

					if not wiz.framework.util.strval.validate(schemaType.data[field].type, userData[field]) # field value passes regex check

						err = '(21)' + errorIncorrectType

					else if userData[field].length < (schemaType.data[field].minlen or 0) # field value is proper length

						err = '(22)' + errorTooShort

					else if userData[field].length > (schemaType.data[field].maxlen or 99999) # field value is proper length

						err = '(23)' + errorTooLong

					else
						# store in output
						outputData[field] = userData[field]
				#}}}
				else #{{{ invalid field value

					err = '(9)' + errorIncorrectType
				#}}}

			else
				err = "missing required field #{field}" unless not schemaType.data.required or updating

			if err

				wiz.log.err(err)
				res.send(400, err)
				return false

		if not updating and userRequired < schemaRequired
			err = "missing required valid fields (only #{userRequired} of required #{schemaRequired} fields)"
			wiz.log.err(err)
			res.send(400, err)
			return false

		return new this(userType, outputData)
	#}}}
	@fromUserUpdate: (req, res, userType, origObj, userData) => #{{{
		docOld = new this(userType, origObj[@dataKey])
		return false unless docOld
		docNew = @fromUser(req, res, userType, userData, true)
		return false unless docNew

		@fromUserMerge(req, res, userType, docOld, docNew)
		#this.__super__.constructor.fromUserMerge(req, res, userType, docOld, docNew)
	#}}}
	@fromUserMerge: (req, res, userType, docOld, docNew) => #{{{
		return false if not schemaType = @types[userType]
		# create new doc to merge old doc with new doc
		doc = new this(userType, {})
		for key of schemaType.data
			if docNew[@dataKey][key]?
				doc[@dataKey][key] = docNew[@dataKey][key]
			else
				doc[@dataKey][key] = docOld[@dataKey][key]

		# restore original document id
		doc[@docKey] = docOld[@docKey]

		return doc
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
