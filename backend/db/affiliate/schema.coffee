# copyright 2012 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/database/mongo/doc'
require './_framework/util/strval'
require './_framework/util/datetime'
require './_framework/http/account/authenticate/userpasswd'

wiz.package 'cypherpunk.backend.db.affiliate.schema'

class type
	constructor: (@type, @description, @verb, @data, @creatable = true) ->

class cypherpunk.backend.db.affiliate.schema extends wiz.framework.database.mongo.docMultiType

	@passwordKey: 'password'
	@affiliateKey: 'affiliate'
	@confirmedKey: 'confirmed'
	@confirmationTokenKey: 'confirmationToken'
	@subscriptionPlanKey: 'subscriptionPlan'
	@subscriptionRenewalKey: 'subscriptionRenewal'
	@subscriptionExpirationKey: 'subscriptionExpiration'

	@fromStranger: (req, res) => #{{{
		return @fromUser(req, res, 'affiliate', req.body)
	#}}}
	@fromUser: (req, res, affiliateType, affiliateData, updating = false) => #{{{

		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUser(req, res, affiliateType, affiliateData, updating)

		return false unless doc

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
	@fromUserUpdate: (req, res, affiliateType, origObj, affiliateData) => #{{{

		# if updating, we might have no password passed.
		# if so, delete it, and restore the original pw hash
		# to the resulting object.
		if affiliateData[@passwordKey]? and typeof affiliateData[@passwordKey] is 'string'
			# only update password if valid new password specified
			if affiliateData[@passwordKey] == ''
				delete affiliateData[@passwordKey]

		# create old and new documents for merging
		docOld = new this(affiliateType, origObj[@dataKey])
		return false unless docOld
		docNew = @fromUser(req, res, affiliateType, affiliateData, true)
		return false unless docNew

		# merge docs
		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUserMerge(req, res, affiliateType, docOld, docNew)
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

# vim: foldmethod=marker wrap
