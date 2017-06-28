# copyright 2012 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/database/mongo/doc'
require './_framework/util/strval'
require './_framework/util/datetime'
require './_framework/http/account/authenticate/userpasswd'

wiz.package 'cypherpunk.backend.db.receipt.schema'

class type
	constructor: (@type, @description, @verb, @data, @creatable = true) ->

class cypherpunk.backend.db.receipt.schema extends wiz.framework.database.mongo.docMultiType

	@fromUser: (req, res, receiptType, receiptData, updating = false) => #{{{

		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUser(req, res, receiptType, receiptData, updating)

		return false unless doc

		if doc?[@dataKey]?[@passwordKey]?  # hash password
			doc[@dataKey][@passwordKey] = wiz.framework.http.account.authenticate.userpasswd.pwHash(doc[@dataKey][@passwordKey])

		return doc
	#}}}
	@fromUserUpdate: (req, res, receiptType, origObj, receiptData) => #{{{

		# if updating, we might have no password passed.
		# if so, delete it, and restore the original pw hash
		# to the resulting object.
		if receiptData[@passwordKey]? and typeof receiptData[@passwordKey] is 'string'
			# only update password if valid new password specified
			if receiptData[@passwordKey] == ''
				delete receiptData[@passwordKey]

		# create old and new documents for merging
		docOld = new this(receiptType, origObj[@dataKey])
		return false unless docOld
		docNew = @fromUser(req, res, receiptType, receiptData, true)
		return false unless docNew

		# merge docs
		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUserMerge(req, res, receiptType, docOld, docNew)
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

		charge: (new type 'charge', 'Charge Receipt', 'list', #{{{
			accountID:
				label: 'cypherpunk customer id'
				placeholder: '4XUYJWGG4LHKMHCLKL7OTIWP7O4UVBJCGO2PIPMXQVV2NZNO2UF'
				type: 'asciiNoSpace'
				maxlen: 90
				required: true
				disabled: true

			transactionID:
				label: 'payment provider transaction id'
				placeholder: 'ch_1AUZvOCymPOZwO5r0eZRKSsx'
				type: 'asciiNoSpace'
				maxlen: 90
				required: true
				disabled: true

			paymentTS:
				label: 'transaction timestamp'
				type: 'isodate'
				required: true
				disabled: true

			description:
				label: 'transaction description'
				placeholder: 'monthly charges for June 2015'
				type: 'ascii'
				maxlen: 150
				disabled: true

			method:
				label: 'payment method'
				placeholder: 'Visa 1337'
				type: 'ascii'
				maxlen: 90
				disabled: true

			currency:
				label: 'charge currency'
				placeholder: 'succeeded'
				type: 'asciiNoSpace'
				maxlen: 50
				required: true
				disabled: true

			amount:
				label: 'receipt amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
				disabled: true
		) #}}}

# vim: foldmethod=marker wrap
