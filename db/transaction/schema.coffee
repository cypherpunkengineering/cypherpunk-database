# copyright 2012 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/database/mongo/doc'
require './_framework/util/strval'
require './_framework/util/datetime'
require './_framework/http/account/authenticate/userpasswd'

wiz.package 'cypherpunk.backend.db.transaction.schema'

class type
	constructor: (@type, @description, @verb, @data, @creatable = true) ->

class cypherpunk.backend.db.transaction.schema extends wiz.framework.database.mongo.docMultiType

	@passwordKey: 'password'

	constructor: () -> #{{{ XXX cannot use this constructor
		throw Error this constructor cannot be used because of the below __super__.constructor() call
	#}}}

	@fromUser: (req, res, transactionType, transactionData, updating = false) => #{{{

		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUser(req, res, transactionType, transactionData, updating)

		return false unless doc

		if doc?[@dataKey]?[@passwordKey]?  # hash password
			doc[@dataKey][@passwordKey] = wiz.framework.http.account.authenticate.userpasswd.pwHash(doc[@dataKey][@passwordKey])

		return doc
	#}}}
	@fromUserUpdate: (req, res, transactionType, origObj, transactionData) => #{{{

		# if updating, we might have no password passed.
		# if so, delete it, and restore the original pw hash
		# to the resulting object.
		if transactionData[@passwordKey]? and typeof transactionData[@passwordKey] is 'string'
			# only update password if valid new password specified
			if transactionData[@passwordKey] == ''
				delete transactionData[@passwordKey]

		# create old and new documents for merging
		docOld = new this(transactionType, origObj[@dataKey])
		return false unless docOld
		docNew = @fromUser(req, res, transactionType, transactionData, true)
		return false unless docNew

		# merge docs
		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUserMerge(req, res, transactionType, docOld, docNew)
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
		stripe: (new type 'stripe', 'Stripe', 'list', #{{{
			txid:
				label: 'transaction id'
				placeholder: 'XXXXXXXXX'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'transaction amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}
		paypal: (new type 'paypal', 'PayPal', 'list', #{{{
			txid:
				label: 'transaction id'
				placeholder: 'XXXXXXXXX'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'transaction amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}
		amazon: (new type 'amazon', 'Amazon', 'list', #{{{
			txid:
				label: 'transaction id'
				placeholder: 'XXXXXXXXX'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'transaction amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}
		bitpay: (new type 'bitpay', 'BitPay', 'list', #{{{
			txid:
				label: 'transaction id'
				placeholder: 'XXXXXXXXX'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'transaction amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}
		googleplay: (new type 'googleplay', 'Google Play', 'list', #{{{
			txid:
				label: 'transaction id'
				placeholder: 'XXXXXXXXX'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'transaction amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}
		appleitunes: (new type 'appleitunes', 'Apple iTunes', 'list', #{{{
			txid:
				label: 'transaction id'
				placeholder: 'XXXXXXXXX'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'transaction amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}

# vim: foldmethod=marker wrap
