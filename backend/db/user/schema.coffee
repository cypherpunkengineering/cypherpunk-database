require './_framework'
require './_framework/database/mongo/doc'
require './_framework/util/strval'
require './_framework/util/datetime'
require './_framework/crypto/hash'
require './_framework/http/account/authenticate/userpasswd'

crypto = require 'crypto'
BigInteger = require './_framework/crypto/jsbn'

wiz.package 'cypherpunk.backend.db.user.schema'

class type
	constructor: (@type, @description, @verb, @data, @creatable = true) ->

class cypherpunk.backend.db.user.schema extends wiz.framework.database.mongo.docMultiType

	@passwordKey: 'password'
	@userKey: 'user'
	@confirmedKey: 'confirmed'
	@confirmationTokenKey: 'confirmationToken'
	@amazonBillingAgreementIDKey: 'amazonBillingAgreementID'
	@stripeCustomerIDKey: 'stripeCustomerID'
	@subscriptionCurrentIDKey: 'subscriptionCurrentID'
	@privacyKey: 'privacy'
	@privacyUserKey: 'username'
	@privacyPassKey: 'password'

	@fromSignup: (req, res) => #{{{
		# FIXME: sanitize all user inputs instead of blindly accepting all given req.body params
		return @fromUser(req, res, 'free', req.body)
	#}}}
	@fromTeaser: (req, res) => #{{{
		# FIXME: sanitize all user inputs instead of blindly accepting all given req.body params
		return @fromUser(req, res, 'invitation', req.body)
	#}}}

	@fromUser: (req, res, userType, userData, updating = false) => #{{{
		# make new doc
		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUser(req, res, userType, userData, updating)
		return false unless doc

		# init user params
		doc = @initParams(doc)

		# hash new password
		if doc?[@dataKey]?[@passwordKey]? # hash password
			doc[@dataKey][@passwordKey] = wiz.framework.http.account.authenticate.userpasswd.pwHash(doc[@dataKey][@passwordKey])

		return doc
	#}}}
	@fromUserUpdate: (req, res, userType, docOld, userData) => #{{{
		# check if old doc given
		return null unless docOld

		# init any un-set params
		docOld = @initParams(docOld)

		# if updating, we might have no password passed.
		# if so, delete it, and restore the original pw hash
		# to the resulting new object.
		if userData[@passwordKey]? and typeof userData[@passwordKey] is 'string'
			# only update password if valid new password specified
			if userData[@passwordKey] == ''
				delete userData[@passwordKey]

		# make new doc
		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUserUpdate(req, res, userType, docOld, userData)
		return false unless doc

		# check if changing password
		if userData[@passwordKey]? and doc?[@dataKey]?[@passwordKey]? # if so, hash password
			doc[@dataKey][@passwordKey] = wiz.framework.http.account.authenticate.userpasswd.pwHash(doc[@dataKey][@passwordKey])

		else if not doc[@dataKey]?[@passwordKey]? # restore original password hash
			doc[@dataKey][@passwordKey] = origObj[@dataKey][@passwordKey]

		return doc
	#}}}

	@initParams: (doc) => #{{{
		doc[@confirmationTokenKey] ?= wiz.framework.crypto.hash.digest
			payload: doc

		doc[@dataKey][@confirmedKey] ?= false
		doc[@dataKey][@subscriptionCurrentIDKey] ?= '0'
		doc[@dataKey][@amazonBillingAgreementIDKey] ?= null
		doc[@dataKey][@stripeCustomerIDKey] ?= null
		doc[@dataKey][@subscriptionCurrentIDKey] ?= null

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

	# customer accounts
		invitation: (new type 'invitation', 'Pending Invitation', 'list', #{{{
			email:
				label: 'email address'
				placeholder: 'satoshin@gmx.com'
				type: 'email'
				maxlen: 50
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

			stripeCustomerID:
				label: 'Stripe Customer ID'
				type: 'asciiNoSpace'
				maxlen: 50
				disabled: true

			paypalSubscriptionID:
				label: 'Paypal Subscription ID'
				type: 'asciiNoSpace'
				maxlen: 50
				disabled: true

			amazonBillingAgreementID:
				label: 'Amazon Billing Agreement ID'
				type: 'asciiNoSpace'
				maxlen: 50
				disabled: true

			subscriptionCurrentID:
				label: 'Current Subscription ID'
				type: 'asciiNoSpace'
				disabled: true

		) #}}}
		expired: (new type 'expired', 'Expired Account', 'list', #{{{
			email:
				label: 'email address'
				placeholder: 'satoshin@gmx.com'
				type: 'email'
				maxlen: 50
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

			stripeCustomerID:
				label: 'Stripe Customer ID'
				type: 'asciiNoSpace'
				disabled: true

			paypalSubscriptionID:
				label: 'Paypal Subscription ID'
				type: 'asciiNoSpace'
				maxlen: 50
				disabled: true

			amazonBillingAgreementID:
				label: 'Amazon Billing Agreement ID'
				type: 'asciiNoSpace'
				disabled: true

			subscriptionCurrentID:
				label: 'Current Subscription ID'
				type: 'asciiNoSpace'
				disabled: true

		) #}}}
		free: (new type 'free', 'Free Account', 'list', #{{{
			email:
				label: 'email address'
				placeholder: 'satoshin@gmx.com'
				type: 'email'
				maxlen: 50
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

			stripeCustomerID:
				label: 'Stripe Customer ID'
				type: 'asciiNoSpace'
				disabled: true

			paypalSubscriptionID:
				label: 'Paypal Subscription ID'
				type: 'asciiNoSpace'
				maxlen: 50
				disabled: true

			amazonBillingAgreementID:
				label: 'Amazon Billing Agreement ID'
				type: 'asciiNoSpace'
				disabled: true

			subscriptionCurrentID:
				label: 'Current Subscription ID'
				type: 'asciiNoSpace'
				disabled: true

		) #}}}
		premium: (new type 'premium', 'Premium Account', 'list', #{{{
			email:
				label: 'email address'
				placeholder: 'satoshin@gmx.com'
				type: 'email'
				maxlen: 50
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

			stripeCustomerID:
				label: 'Stripe Customer ID'
				type: 'asciiNoSpace'
				disabled: true

			paypalSubscriptionID:
				label: 'Paypal Subscription ID'
				type: 'asciiNoSpace'
				maxlen: 50
				disabled: true

			amazonBillingAgreementID:
				label: 'Amazon Billing Agreement ID'
				type: 'asciiNoSpace'
				disabled: true

			subscriptionCurrentID:
				label: 'Current Subscription ID'
				type: 'asciiNoSpace'
				disabled: true
		) #}}}
		family: (new type 'family', 'Family Account', 'list', #{{{
			email:
				label: 'email address'
				placeholder: 'satoshin@gmx.com'
				type: 'email'
				maxlen: 50
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

			stripeCustomerID:
				label: 'Stripe Customer ID'
				type: 'asciiNoSpace'
				disabled: true

			paypalSubscriptionID:
				label: 'Paypal Subscription ID'
				type: 'asciiNoSpace'
				maxlen: 50
				disabled: true

			amazonBillingAgreementID:
				label: 'Amazon Billing Agreement ID'
				type: 'asciiNoSpace'
				disabled: true

			subscriptionCurrentID:
				label: 'Current Subscription ID'
				type: 'asciiNoSpace'
				disabled: true
		) #}}}
		enterprise: (new type 'enterprise', 'Enterprise Account', 'list', #{{{
			email:
				label: 'email address'
				placeholder: 'satoshin@gmx.com'
				type: 'email'
				maxlen: 50
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

			stripeCustomerID:
				label: 'Stripe Customer ID'
				type: 'asciiNoSpace'
				disabled: true

			paypalSubscriptionID:
				label: 'Paypal Subscription ID'
				type: 'asciiNoSpace'
				maxlen: 50
				disabled: true

			amazonBillingAgreementID:
				label: 'Amazon Billing Agreement ID'
				type: 'asciiNoSpace'
				disabled: true

			subscriptionCurrentID:
				label: 'Current Subscription ID'
				type: 'asciiNoSpace'
				disabled: true
		) #}}}

	# staff accounts
		staff: (new type 'staff', 'Cypherpunk Account', 'list', #{{{
			email:
				label: 'email address'
				placeholder: 'satoshin@gmx.com'
				type: 'email'
				maxlen: 50
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

			stripeCustomerID:
				label: 'Stripe Customer ID'
				type: 'asciiNoSpace'
				disabled: true

			paypalSubscriptionID:
				label: 'Paypal Subscription ID'
				type: 'asciiNoSpace'
				maxlen: 50
				disabled: true

			amazonBillingAgreementID:
				label: 'Amazon Billing Agreement ID'
				type: 'asciiNoSpace'
				disabled: true

			subscriptionCurrentID:
				label: 'Current Subscription ID'
				type: 'asciiNoSpace'
				disabled: true
		) #}}}
		developer: (new type 'developer', 'Cypherpunk Developer', 'list', #{{{
			email:
				label: 'email address'
				placeholder: 'satoshin@gmx.com'
				type: 'email'
				maxlen: 50
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

			stripeCustomerID:
				label: 'Stripe Customer ID'
				type: 'asciiNoSpace'
				disabled: true

			paypalSubscriptionID:
				label: 'Paypal Subscription ID'
				type: 'asciiNoSpace'
				maxlen: 50
				disabled: true

			amazonBillingAgreementID:
				label: 'Amazon Billing Agreement ID'
				type: 'asciiNoSpace'
				disabled: true

			subscriptionCurrentID:
				label: 'Current Subscription ID'
				type: 'asciiNoSpace'
				disabled: true
		) #}}}

# vim: foldmethod=marker wrap
