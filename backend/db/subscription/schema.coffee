# copyright 2012 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/database/mongo/doc'
require './_framework/util/strval'
require './_framework/util/datetime'
require './_framework/http/account/authenticate/userpasswd'

wiz.package 'cypherpunk.backend.db.subscription.schema'

class type
	constructor: (@type, @description, @verb, @data, @creatable = true) ->

class cypherpunk.backend.db.subscription.schema extends wiz.framework.database.mongo.docMultiType

	@fromUser: (req, res, subscriptionType, subscriptionData, updating = false) => #{{{

		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUser(req, res, subscriptionType, subscriptionData, updating)

		return false unless doc

		if doc?[@dataKey]?[@passwordKey]?  # hash password
			doc[@dataKey][@passwordKey] = wiz.framework.http.account.authenticate.userpasswd.pwHash(doc[@dataKey][@passwordKey])

		return doc
	#}}}
	@fromUserUpdate: (req, res, subscriptionType, origObj, subscriptionData) => #{{{

		# if updating, we might have no password passed.
		# if so, delete it, and restore the original pw hash
		# to the resulting object.
		if subscriptionData[@passwordKey]? and typeof subscriptionData[@passwordKey] is 'string'
			# only update password if valid new password specified
			if subscriptionData[@passwordKey] == ''
				delete subscriptionData[@passwordKey]

		# create old and new documents for merging
		docOld = new this(subscriptionType, origObj[@dataKey])
		return false unless docOld
		docNew = @fromUser(req, res, subscriptionType, subscriptionData, true)
		return false unless docNew

		# merge docs
		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUserMerge(req, res, subscriptionType, docOld, docNew)
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
#  id: 'cus_9djahSvYrD1w4w'
#  object: 'customer'
#  account_balance: 0
#  created: 1480251078
#  currency: 'usd'
#  default_source: 'card_19KS7kCymPOZwO5rVFqdx2NF'
#  delinquent: false
#  description: null
#  discount: null
#  email: 'jmaurice+stripe2@cypherpunk.com'
#  livemode: false
#  metadata: {}
#  shipping: null
#  sources:
#     object: 'list'
#     data: [ [ Object ] ]
#     has_more: false
#     total_count: 1
#     url: '/v1/customers/cus_9djahSvYrD1w4w/sources'
#  subscriptions:
#     object: 'list'
#     data: [ [ Object ] ]
#     has_more: false
#     total_count: 1
#     url: '/v1/customers/cus_9djahSvYrD1w4w/subscriptions'

		monthly: (new type 'monthly', 'Monthly Subscription', 'list', #{{{
			plan:
				label: 'subscription plan'
				placeholder: 'monthly899'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			purchaseTS:
				label: 'subscription purchased on'
				type: 'isodate'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}
		semiannually: (new type 'semiannually', 'Semiannual Subscription', 'list', #{{{
			plan:
				label: 'subscription plan'
				placeholder: 'semiannually4494'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			renewal:
				label: 'subscription renewal'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}
		annually: (new type 'annually', 'Annual Subscription', 'list', #{{{
			plan:
				label: 'subscription plan'
				placeholder: 'annually5988'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			renewal:
				label: 'subscription renewal'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}

# vim: foldmethod=marker wrap