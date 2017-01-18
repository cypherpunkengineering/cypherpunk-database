# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../../db/user'

require './source'
require './register'
require './confirm'
require './upgrade'

wiz.package 'cypherpunk.backend.api.v0.account'

class cypherpunk.backend.api.v0.account.module extends wiz.framework.http.account.module
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	database: null

	accountinfo: (req) => #{{{ returns a (safe to send) object containing account info from a account object
		session = req?.session
		account = session?.account
		data = account?.data
		privacy = account?.privacy

		out = {}
		if session? and account? and data? and privacy?
			out =
				secret: session?.secret
				privacy:
					username: privacy?.username
					password: privacy?.password
				account:
					id: account?.id
					email: data?.email
					confirmed: (if data?.confirmed?.toString() == "true" then true else false)
					type: account?.type
				subscription:
					renewal: data?.subscriptionRenewal
					expiration: data?.subscriptionExpiration
		else
			wiz.log.err "accountinfo contains missing required data!"

		console.log out
		return out
	#}}}
	load: () => #{{{
		super()

		# public account creation api
		@routeAdd new cypherpunk.backend.api.v0.account.register.resource(@server, this, 'register')
		# public account confirmation api
		@routeAdd new cypherpunk.backend.api.v0.account.confirm.resource(@server, this, 'confirm')
		# public account upgrade api
		@routeAdd new cypherpunk.backend.api.v0.account.upgrade.resource(@server, this, 'upgrade')

		# customer source api (proxy to stripe)
		@routeAdd new cypherpunk.backend.api.v0.account.source.resource(@server, this, 'source')
	#}}}
	init: () => #{{{
		@database = new cypherpunk.backend.db.user(@server, this, @parent.parent.cypherpunkDB)
		super()
	#}}}

# vim: foldmethod=marker wrap
