# copyright 2012 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/database/mongo/doc'
require './_framework/util/strval'
require './_framework/util/datetime'
require './_framework/http/account/authenticate/userpasswd'

wiz.package 'cypherpunk.backend.db.admin.schema'

class type
	constructor: (@type, @description, @verb, @data, @creatable = true) ->

class cypherpunk.backend.db.admin.schema extends wiz.framework.database.mongo.docMultiType

	@passwordKey: 'password'

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
		return doc
	#}}}

	class type #{{{
		constructor: (@type, @description, @verb, @data, @creatable = true) ->
	@types:
	#}}}

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
		marketing: (new type 'marketing', 'Marketing Employee', 'list', #{{{
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
		legal: (new type 'legal', 'Legal Counsel', 'list', #{{{
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
		executive: (new type 'executive', 'Executive', 'list', #{{{
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

		engineer: (new type 'engineer', 'Engineer', 'list', #{{{
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
		wiz: (new type 'wiz', 'wiz', 'list', #{{{
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
