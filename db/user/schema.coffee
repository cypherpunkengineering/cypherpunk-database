# copyright 2012 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/database/mongo/doc'
require './_framework/util/strval'
require './_framework/util/datetime'
require './_framework/http/acct/authenticate/userpasswd'

wiz.package 'cypherpunk.backend.db.user.schema'

class type
	constructor: (@type, @description, @verb, @data, @creatable = true) ->

class cypherpunk.backend.db.user.schema extends wiz.framework.database.mongo.docMultiType

	@passwordKey: 'password'
	@customerKey: 'customer'
	@confirmedKey: 'confirmed'
	@confirmationTokenKey: 'confirmationToken'
	@subscriptionTypeKey: 'subscriptionType'
	@subscriptionRenewalKey: 'subscriptionRenewal'
	@subscriptionExpirationKey: 'subscriptionExpiration'

	constructor: () -> #{{{ XXX cannot use this constructor
		throw Error this constructor cannot be used because of the below __super__.constructor() call
	#}}}
	@fromStranger: (req, res) => #{{{
		return @fromUser(req, res, 'customer', req.body)
	#}}}
	@fromUser: (req, res, userType, userData, updating = false) => #{{{

		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUser(req, res, userType, userData, updating)

		doc[@confirmedKey] = false

		doc[@dataKey][@subscriptionTypeKey] ?= 'free'
		doc[@dataKey][@subscriptionRenewalKey] ?= 'none'
		doc[@dataKey][@subscriptionExpirationKey] ?= '0'

		doc[@confirmationTokenKey] ?= wiz.framework.crypto.hash.digest
			payload: doc

		return false unless doc

		if doc?[@dataKey]?[@passwordKey]?  # hash password
			doc[@dataKey][@passwordKey] = wiz.framework.http.acct.authenticate.userpasswd.pwHash(doc[@dataKey][@passwordKey])

		return doc
	#}}}
	@fromUserUpdate: (req, res, userType, origObj, userData) => #{{{

		# if updating, we might have no password passed.
		# if so, delete it, and restore the original pw hash
		# to the resulting object.
		if userData[@passwordKey]? and typeof userData[@passwordKey] is 'string'
			# only update password if valid new password specified
			if userData[@passwordKey] == ''
				delete userData[@passwordKey]

		# create old and new documents for merging
		docOld = new this(userType, origObj[@dataKey])
		return false unless docOld
		docNew = @fromUser(req, res, userType, userData, true)
		return false unless docNew

		# merge docs
		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUserMerge(req, res, userType, docOld, docNew)
		return false unless doc

		# restore original password hash
		if not doc[@dataKey]?[@passwordKey]?
			doc[@dataKey][@passwordKey] = origObj[@dataKey][@passwordKey]

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

			password:
				label: 'set password'
				type: 'asciiNoSpace'
				minlen: 6
				maxlen: 50
				placeholder: ''
				required: true

			subscriptionType:
				label: 'subscription type'
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
		affiliate: (new type 'affiliate', 'Affiliate', 'list', #{{{
			email:
				label: 'email address'
				placeholder: 'satoshin@gmx.com'
				type: 'email'
				maxlen: 30
				required: true

			fullname:
				label: 'full name'
				type: 'ascii'
				maxlen: 50
				placeholder: 'Satoshi Nakamoto'
				required: true

			password:
				label: 'set password'
				type: 'asciiNoSpace'
				minlen: 6
				maxlen: 50
				placeholder: ''
				required: true

		) #}}}
		support: (new type 'support', 'Support Agent', 'list', #{{{
			email:
				label: 'email address'
				placeholder: 'satoshin@gmx.com'
				type: 'email'
				maxlen: 30
				required: true

			fullname:
				label: 'full name'
				type: 'ascii'
				maxlen: 50
				placeholder: 'Satoshi Nakamoto'
				required: true

			password:
				label: 'set password'
				type: 'asciiNoSpace'
				minlen: 6
				maxlen: 50
				placeholder: ''
				required: true

		) #}}}
		legal: (new type 'legal', 'Attorney', 'list', #{{{
			email:
				label: 'email address'
				placeholder: 'satoshin@gmx.com'
				type: 'email'
				maxlen: 30
				required: true

			fullname:
				label: 'full name'
				type: 'ascii'
				maxlen: 50
				placeholder: 'Satoshi Nakamoto'
				required: true

			password:
				label: 'set password'
				type: 'asciiNoSpace'
				minlen: 6
				maxlen: 50
				placeholder: ''
				required: true

		) #}}}
		admin: (new type 'admin', 'Administrator', 'list', #{{{
			email:
				label: 'email address'
				placeholder: 'satoshin@gmx.com'
				type: 'email'
				maxlen: 30
				required: true

			fullname:
				label: 'full name'
				type: 'ascii'
				maxlen: 50
				placeholder: 'Satoshi Nakamoto'
				required: true

			password:
				label: 'set password'
				type: 'asciiNoSpace'
				minlen: 6
				maxlen: 50
				placeholder: ''
				required: true
		) #}}}

# vim: foldmethod=marker wrap
