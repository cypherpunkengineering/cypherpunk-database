
# copyright 2012 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/database/mongo/doc'
require './_framework/util/strval'
require './_framework/util/datetime'
require './_framework/http/account/authenticate/userpasswd'

wiz.package 'cypherpunk.backend.db.charge.schema'

class type
	constructor: (@type, @description, @verb, @data, @creatable = true) ->

class cypherpunk.backend.db.charge.schema extends wiz.framework.database.mongo.docMultiType

	@fromUser: (req, res, chargeType, chargeData, updating = false) => #{{{

		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUser(req, res, chargeType, chargeData, updating)

		return false unless doc

		if doc?[@dataKey]?[@passwordKey]?  # hash password
			doc[@dataKey][@passwordKey] = wiz.framework.http.account.authenticate.userpasswd.pwHash(doc[@dataKey][@passwordKey])

		return doc
	#}}}
	@fromUserUpdate: (req, res, chargeType, origObj, chargeData) => #{{{

		# if updating, we might have no password passed.
		# if so, delete it, and restore the original pw hash
		# to the resulting object.
		if chargeData[@passwordKey]? and typeof chargeData[@passwordKey] is 'string'
			# only update password if valid new password specified
			if chargeData[@passwordKey] == ''
				delete chargeData[@passwordKey]

		# create old and new documents for merging
		docOld = new this(chargeType, origObj[@dataKey])
		return false unless docOld
		docNew = @fromUser(req, res, chargeType, chargeData, true)
		return false unless docNew

		# merge docs
		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUserMerge(req, res, chargeType, docOld, docNew)
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

		stripe: (new type 'stripe', 'Stripe Charge', 'list', #{{{
			id:
				label: 'charge id'
				placeholder: 'ch_1AUZvOCymPOZwO5r0eZRKSsx'
				type: 'asciiNoSpace'
				maxlen: 40
				required: true
				disabled: true

			customer:
				label: 'stripe customer id'
				placeholder: 'cus_9djahSvYrD1w4w'
				type: 'asciiNoSpace'
				maxlen: 40
				required: true
				disabled: true

			cypherpunk_account_id:
				label: 'cypherpunk customer id'
				placeholder: '4XUYJWGG4LHKMHCLKL7OTIWP7O4UVBJCGO2PIPMXQVV2NZNO2UF'
				type: 'asciiNoSpace'
				maxlen: 90
				required: true
				disabled: true

			invoice:
				label: 'stripe invoice id'
				placeholder: 'in_1AUZvOCymPOZwO5rEro2RfRO'
				type: 'asciiNoSpace'
				maxlen: 40
				required: true
				disabled: true

			amount:
				label: 'charge amount'
				type: 'int'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
				disabled: true

			amount_refunded:
				label: 'charge amount refunded'
				type: 'int'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
				disabled: true

			currency:
				label: 'charge currency'
				placeholder: 'succeeded'
				type: 'asciiNoSpace'
				maxlen: 50
				required: true
				disabled: true

			balance_transaction:
				label: 'charge balance transaction id'
				placeholder: 'txn_1AUZvOCymPOZwO5ro8AiQxeW'
				type: 'asciiNoSpace'
				maxlen: 90
				required: true
				disabled: true

			status:
				label: 'charge status'
				placeholder: 'succeeded'
				type: 'asciiNoSpace'
				maxlen: 50
				required: true
				disabled: true
		) #}}}
		paypal: (new type 'paypal', 'PayPal Payment', 'list', #{{{
			txn_id:
				label: 'paypal transaction id'
				placeholder: '8G714942TJ100635R'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true
				disabled: true

			txn_type:
				label: 'paypal transaction type'
				placeholder: '8G714942TJ100635R'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true
				disabled: true

			cypherpunk_account_id:
				label: 'cypherpunk customer id'
				placeholder: '4XUYJWGG4LHKMHCLKL7OTIWP7O4UVBJCGO2PIPMXQVV2NZNO2UF'
				type: 'asciiNoSpace'
				maxlen: 90
				required: true
				disabled: true

			cypherpunk_plan_type:
				label: 'cypherpunk plan type'
				placeholder: 'daily, monthly, semiannually, or annually'
				type: 'asciiNoSpace'
				maxlen: 50
				required: true
				disabled: true

			payer_id:
				label: 'paypal payer id'
				placeholder: 'KXB398KPF7VMW'
				type: 'asciiNoSpace'
				maxlen: 50
				required: true
				disabled: true

			payer_email:
				label: 'paypal payer email'
				placeholder: 'satoshi@paypal.com'
				type: 'email'
				maxlen: 50
				required: true
				disabled: true

			payer_status:
				label: 'paypal payer status'
				placeholder: 'verified'
				type: 'asciiNoSpace'
				maxlen: 50
				required: true
				disabled: true

			payment_date:
				label: 'paypal payment date'
				placeholder: '03:15:18 Jun 12, 2017 PDT'
				type: 'ascii'
				maxlen: 70
				required: true
				disabled: true

			payment_type:
				label: 'paypal payment type'
				placeholder: 'instant'
				type: 'asciiNoSpace'
				maxlen: 50
				required: true
				disabled: true

			payment_status:
				label: 'paypal payment status'
				placeholder: 'Completed'
				type: 'asciiNoSpace'
				maxlen: 50
				required: true
				disabled: true

			mc_gross:
				label: 'payment amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
				disabled: true

			mc_fee:
				label: 'payment fee'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
				disabled: true

			mc_currency:
				label: 'payment currency'
				type: 'asciiNoSpace'
				maxlen: 10
				placeholder: 'USD'
				required: true
				disabled: true

			first_name:
				label: 'paypal payer first name'
				placeholder: 'John'
				type: 'ascii'
				maxlen: 80
				required: true
				disabled: true

			last_name:
				label: 'paypal payer last name'
				placeholder: 'Smith'
				type: 'ascii'
				maxlen: 80
				required: true
				disabled: true

			verify_sign:
				label: 'paypal verification signature'
				placeholder: 'AE.pCRu8dAgEChKtiAO8IAX666.2A0L3dEvMwyN3KOTNOlAAKFzs6iin'
				type: 'asciiNoSpace'
				maxlen: 120
				required: true
				disabled: true

		) #}}}
		amazon: (new type 'amazon', 'Amazon Charge', 'list', #{{{
			txid:
				label: 'charge id'
				placeholder: 'XXXXXXXXX'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'charge amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}
		bitpay: (new type 'bitpay', 'BitPay Charge', 'list', #{{{
			invoice_id:
				label: 'bitpay invoice id'
				placeholder: 'Ao5BLYJEZfhQTdqiXVC2Ps'
				type: 'asciiNoSpace'
				maxlen: 50
				required: true
				disabled: true

			btcPaid:
				label: 'bitpay BTC amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '0.0XXXXXXX'
				required: true
				disabled: true

			amount:
				label: 'bitpay invoice amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
				disabled: true

			currency:
				label: 'bitpay invoice currency'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
				disabled: true

			rate:
				label: 'bitpay btc rate'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XXXX.XX'
				required: true
				disabled: true

			cypherpunk_account_id:
				label: 'cypherpunk customer id'
				placeholder: '4XUYJWGG4LHKMHCLKL7OTIWP7O4UVBJCGO2PIPMXQVV2NZNO2UF'
				type: 'asciiNoSpace'
				maxlen: 90
				required: true
				disabled: true

			cypherpunk_plan_type:
				label: 'cypherpunk plan type'
				placeholder: 'daily, monthly, semiannually, or annually'
				type: 'asciiNoSpace'
				maxlen: 50
				required: true
				disabled: true
		) #}}}
		googleplay: (new type 'googleplay', 'Google Play Charge', 'list', #{{{
			txid:
				label: 'charge id'
				placeholder: 'XXXXXXXXX'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'charge amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}
		appleitunes: (new type 'appleitunes', 'Apple iTunes Charge', 'list', #{{{
			txid:
				label: 'charge id'
				placeholder: 'XXXXXXXXX'
				type: 'asciiNoSpace'
				maxlen: 30
				required: true

			amount:
				label: 'charge amount'
				type: 'alphanumericdot'
				maxlen: 50
				placeholder: '$XX.XX'
				required: true
		) #}}}

# vim: foldmethod=marker wrap
