# copyright 2012 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/database/mongo/doc'
require './_framework/util/strval'
require './_framework/util/datetime'
require './_framework/http/account/authenticate/userpasswd'

wiz.package 'cypherpunk.backend.db.invoice.schema'

class type
	constructor: (@type, @description, @verb, @data, @creatable = true) ->

class cypherpunk.backend.db.invoice.schema extends wiz.framework.database.mongo.docMultiType

	@fromUser: (req, res, invoiceType, invoiceData, updating = false) => #{{{

		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUser(req, res, invoiceType, invoiceData, updating)

		return false unless doc

		if doc?[@dataKey]?[@passwordKey]?  # hash password
			doc[@dataKey][@passwordKey] = wiz.framework.http.account.authenticate.userpasswd.pwHash(doc[@dataKey][@passwordKey])

		return doc
	#}}}
	@fromUserUpdate: (req, res, invoiceType, origObj, invoiceData) => #{{{

		# if updating, we might have no password passed.
		# if so, delete it, and restore the original pw hash
		# to the resulting object.
		if invoiceData[@passwordKey]? and typeof invoiceData[@passwordKey] is 'string'
			# only update password if valid new password specified
			if invoiceData[@passwordKey] == ''
				delete invoiceData[@passwordKey]

		# create old and new documents for merging
		docOld = new this(invoiceType, origObj[@dataKey])
		return false unless docOld
		docNew = @fromUser(req, res, invoiceType, invoiceData, true)
		return false unless docNew

		# merge docs
		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUserMerge(req, res, invoiceType, docOld, docNew)
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
#  invoices:
#     object: 'list'
#     data: [ [ Object ] ]
#     has_more: false
#     total_count: 1
#     url: '/v1/customers/cus_9djahSvYrD1w4w/invoices'

		net30: (new type 'net30', 'Invoice', 'list', #{{{
			id:
				label: 'invoice id'
				placeholder: 'cus_9djahSvYrD1w4w'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'invoice amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true

			duedate:
				label: 'due date'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}

# vim: foldmethod=marker wrap
