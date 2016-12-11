# copyright 2012 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/database/mongo/doc'
require './_framework/util/strval'
require './_framework/util/datetime'
require './_framework/http/account/authenticate/userpasswd'

wiz.package 'cypherpunk.backend.db.refund.schema'

class type
	constructor: (@type, @description, @verb, @data, @creatable = true) ->

class cypherpunk.backend.db.refund.schema extends wiz.framework.database.mongo.docMultiType

	@fromUser: (req, res, refundType, refundData, updating = false) => #{{{

		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUser(req, res, refundType, refundData, updating)

		return false unless doc

		if doc?[@dataKey]?[@passwordKey]?  # hash password
			doc[@dataKey][@passwordKey] = wiz.framework.http.account.authenticate.userpasswd.pwHash(doc[@dataKey][@passwordKey])

		return doc
	#}}}
	@fromUserUpdate: (req, res, refundType, origObj, refundData) => #{{{

		# if updating, we might have no password passed.
		# if so, delete it, and restore the original pw hash
		# to the resulting object.
		if refundData[@passwordKey]? and typeof refundData[@passwordKey] is 'string'
			# only update password if valid new password specified
			if refundData[@passwordKey] == ''
				delete refundData[@passwordKey]

		# create old and new documents for merging
		docOld = new this(refundType, origObj[@dataKey])
		return false unless docOld
		docNew = @fromUser(req, res, refundType, refundData, true)
		return false unless docNew

		# merge docs
		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUserMerge(req, res, refundType, docOld, docNew)
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

		stripe: (new type 'stripe', 'Stripe Refund', 'list', #{{{
			id:
				label: 'refund id'
				placeholder: 'cus_9djahSvYrD1w4w'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'refund amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}
		paypal: (new type 'paypal', 'PayPal Refund', 'list', #{{{
			txid:
				label: 'refund id'
				placeholder: 'XXXXXXXXX'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'refund amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}
		amazon: (new type 'amazon', 'Amazon Refund', 'list', #{{{
			txid:
				label: 'refund id'
				placeholder: 'XXXXXXXXX'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'refund amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}
		bitpay: (new type 'bitpay', 'BitPay Refund', 'list', #{{{
			txid:
				label: 'refund id'
				placeholder: 'XXXXXXXXX'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'refund amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}
		googleplay: (new type 'googleplay', 'Google Play Refund', 'list', #{{{
			txid:
				label: 'refund id'
				placeholder: 'XXXXXXXXX'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'refund amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}
		appleitunes: (new type 'appleitunes', 'Apple iTunes Refund', 'list', #{{{
			txid:
				label: 'refund id'
				placeholder: 'XXXXXXXXX'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'refund amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}

# vim: foldmethod=marker wrap
