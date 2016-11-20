# copyright 2012 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/database/mongo/doc'
require './_framework/util/strval'
require './_framework/util/datetime'
require './_framework/crypto/hash'
require './_framework/http/account/authenticate/userpasswd'

crypto = require 'crypto'
BigInteger = require './_framework/crypto/jsbn'

wiz.package 'cypherpunk.backend.db.customer.schema'

class type
	constructor: (@type, @description, @verb, @data, @creatable = true) ->

class cypherpunk.backend.db.customer.schema extends wiz.framework.database.mongo.docMultiType

	@passwordKey: 'password'
	@customerKey: 'customer'
	@confirmedKey: 'confirmed'
	@confirmationTokenKey: 'confirmationToken'
	@subscriptionPlanKey: 'subscriptionPlan'
	@subscriptionRenewalKey: 'subscriptionRenewal'
	@subscriptionExpirationKey: 'subscriptionExpiration'
	@privacyKey: 'privacy'
	@privacyUserKey: 'username'
	@privacyPassKey: 'password'

	@fromStranger: (req, res) => #{{{
		# FIXME: sanitize all user inputs instead of blindly accepting all given req.body params
		return @fromUser(req, res, 'customer', req.body)
	#}}}
	@fromUser: (req, res, customerType, customerData, updating = false) => #{{{

		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUser(req, res, customerType, customerData, updating)

		return false unless doc

		doc = @initParams(doc)

		doc[@dataKey][@confirmedKey] ?= false
		doc[@dataKey][@subscriptionPlanKey] ?= 'free'
		doc[@dataKey][@subscriptionRenewalKey] ?= 'none'
		doc[@dataKey][@subscriptionExpirationKey] ?= '0'

		doc[@confirmationTokenKey] ?= wiz.framework.crypto.hash.digest
			payload: doc

		if doc?[@dataKey]?[@passwordKey]?  # hash password
			doc[@dataKey][@passwordKey] = wiz.framework.http.account.authenticate.userpasswd.pwHash(doc[@dataKey][@passwordKey])

		return doc
	#}}}
	@fromUserUpdate: (req, res, customerType, docOld, customerData) => #{{{
		# if updating, we might have no password passed.
		# if so, delete it, and restore the original pw hash
		# to the resulting object.
		if customerData[@passwordKey]? and typeof customerData[@passwordKey] is 'string'
			# only update password if valid new password specified
			if customerData[@passwordKey] == ''
				delete customerData[@passwordKey]

		# init params if necessary
		docOld = @initParams(docOld)

		# call super
		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUserUpdate(req, res, customerType, docOld, customerData)

		# restore original password hash
		if not doc[@dataKey]?[@passwordKey]?
			doc[@dataKey][@passwordKey] = origObj[@dataKey][@passwordKey]

		return doc
	#}}}

	@initParams: (doc) => #{{{
		doc[@dataKey][@confirmedKey] ?= false
		doc[@dataKey][@subscriptionPlanKey] ?= 'free'
		doc[@dataKey][@subscriptionRenewalKey] ?= 'none'
		doc[@dataKey][@subscriptionExpirationKey] ?= '0'

		doc[@privacyKey] ?= {}
		user = new BigInteger(crypto.randomBytes(16))
		doc[@privacyKey][@privacyUserKey] ?= wiz.framework.crypto.convert.biToBase32(user)
		pass = new BigInteger(crypto.randomBytes(16))
		doc[@privacyKey][@privacyPassKey] ?= wiz.framework.crypto.convert.biToBase32(pass)

		return doc
	#}}}

	class type #{{{
		constructor: (@type, @description, @verb, @data, @creatable = true) ->
	@types:
	#}}}
		customer: (new type 'customer', 'Customer', 'list', #{{{
			email:
				label: 'email address'
				placeholder: 'satoshin@gmx.com'
				type: 'email'
				maxlen: 30
				required: true

			confirmed:
				label: 'email confirmed'
				type: 'boolean'
				required: true

			password:
				label: 'set password'
				type: 'asciiNoSpace'
				minlen: 6
				maxlen: 50
				placeholder: ''
				required: true

			subscriptionPlan:
				label: 'subscription plan'
				type: 'asciiNoSpace'
				minlen: 1
				maxlen: 50
				placeholder: ''
				required: true

			subscriptionRenewal:
				label: 'subscription renewal'
				type: 'asciiNoSpace'
				minlen: 1
				maxlen: 50
				placeholder: ''
				required: true

			subscriptionExpiration:
				label: 'subscription expiration'
				type: 'asciiNoSpace'
				minlen: 1
				maxlen: 50
				placeholder: ''
				required: true
		) #}}}

# vim: foldmethod=marker wrap
