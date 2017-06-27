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

	@providerKey: 'provider'
	@providerSubscriptionIDKey: 'providerSubscriptionID'
	@providerPlanIDKey: 'providerPlanID'
	@purchaseTSKey: 'purchaseTS'
	@renewalTSKey: 'renewalTS'
	@activeKey: 'active'

	@fromUser: (req, res, subscriptionType, subscriptionData, updating = false) => #{{{
		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUser(req, res, subscriptionType, subscriptionData, updating)
		return doc
	#}}}
	@fromUserUpdate: (req, res, subscriptionType, origObj, subscriptionData) => #{{{
		# create old and new documents for merging
		docOld = new this(subscriptionType, origObj[@dataKey])
		return false unless docOld
		docNew = @fromUser(req, res, subscriptionType, subscriptionData, true)
		return false unless docNew

		# merge docs
		this.__super__.constructor.types = @types
		doc = this.__super__.constructor.fromUserMerge(req, res, subscriptionType, docOld, docNew)
		return false unless doc
	#}}}

	class type #{{{
		constructor: (@type, @description, @verb, @data, @creatable = true) ->
	@types:
	#}}}

		trial: (new type 'trial', 'Free Trial', 'list', #{{{
			accountID:
				label: 'cypherpunk customer id'
				placeholder: '4XUYJWGG4LHKMHCLKL7OTIWP7O4UVBJCGO2PIPMXQVV2NZNO2UF'
				type: 'asciiNoSpace'
				maxlen: 90
				required: true
				disabled: true

			startTS:
				label: 'trial start'
				type: 'isodate'
				required: true
				disabled: true

			expirationTS:
				label: 'trial expiration'
				type: 'isodate'
				disabled: true

			active:
				label: 'trial active'
				type: 'boolean'
				required: true
		) #}}}
		elite: (new type 'elite', 'Elite Subscription', 'list', #{{{
			accountID:
				label: 'cypherpunk customer id'
				placeholder: '4XUYJWGG4LHKMHCLKL7OTIWP7O4UVBJCGO2PIPMXQVV2NZNO2UF'
				type: 'asciiNoSpace'
				maxlen: 90
				required: true
				disabled: true

			provider:
				label: 'subscription provider'
				type: 'asciiNoSpace'
				maxlen: 50
				required: true
				disabled: true

			providerSubscriptionID:
				label: 'subscription provider subscription id'
				type: 'asciiNoSpace'
				maxlen: 50
				required: true
				disabled: true

			providerPlanID:
				label: 'subscription provider plan id'
				type: 'asciiNoSpace'
				maxlen: 50
				required: true
				disabled: true

			purchaseTS:
				label: 'subscription purchase'
				type: 'isodate'
				required: true
				disabled: true

			renewalTS:
				label: 'subscription renewal'
				type: 'isodate'
				disabled: true

			expirationTS:
				label: 'subscription expiration'
				type: 'isodate'
				disabled: true

			cancellationTS:
				label: 'subscription cancellation'
				type: 'isodate'
				disabled: true

			currentPeriodStartTS:
				label: 'current period start'
				type: 'isodate'
				required: true
				disabled: true

			currentPeriodEndTS:
				label: 'curent period end'
				type: 'isodate'
				required: true
				disabled: true

			active:
				label: 'subscription active'
				type: 'boolean'
				required: true
		) #}}}

# vim: foldmethod=marker wrap
