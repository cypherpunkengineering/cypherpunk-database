# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../../db/user'

require './change'
require './confirm'
require './purchase'
require './recover'
require './register'
require './source'
require './upgrade'

wiz.package 'cypherpunk.backend.api.v0.account'

class cypherpunk.backend.api.v0.account.module extends wiz.framework.http.account.module
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	database: null

	accountStatus: (req) => #{{{ returns a (safe to send) object containing account info from a account object
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
					type: account?.type
					id: account?.id
					email: data?.email
					confirmed: (if data?.confirmed?.toString() == "true" then true else false)
				subscription:
					active: (if data?.subscriptionActive?.toString() == "false" then false else true)
					renews: (if data?.subscriptionRenews?.toString() == "true" then true else false)
					type: (if data?.subscriptionType? then data?.subscriptionType else (if account?.type is "free" or account?.type is "invitation" then "preview" else "forever"))
					expiration: (if data?.subscriptionExpiration? then data?.subscriptionExpiration else "0")
					# deprecated
					renewal: (if data?.subscriptionRenewal? then data?.subscriptionRenewal else "forever")
		else
			wiz.log.err "accountStatus contains missing required data!"

		wiz.log.info "Queried account status for #{data?.email}"
		console.log out.account
		console.log out.subscription
		return out
	#}}}
	load: () => #{{{
		super()

		@routeAdd new cypherpunk.backend.api.v0.account.change.resource(@server, this, 'change')
		@routeAdd new cypherpunk.backend.api.v0.account.confirm.resource(@server, this, 'confirm')
		@routeAdd new cypherpunk.backend.api.v0.account.purchase.resource(@server, this, 'purchase')
		@routeAdd new cypherpunk.backend.api.v0.account.recover.resource(@server, this, 'recover')
		@routeAdd new cypherpunk.backend.api.v0.account.register.resource(@server, this, 'register')
		@routeAdd new cypherpunk.backend.api.v0.account.upgrade.resource(@server, this, 'upgrade')
		@routeAdd new cypherpunk.backend.api.v0.account.source.resource(@server, this, 'source')
	#}}}
	init: () => #{{{
		@database = new cypherpunk.backend.db.user(@server, this, @parent.parent.cypherpunkDB)
		super()
	#}}}

# vim: foldmethod=marker wrap
