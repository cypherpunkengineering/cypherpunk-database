# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/account'
require './_framework/http/resource/base'
require './_framework/thirdparty/stripe'

wiz.package 'cypherpunk.backend.api.v0.account.confirm'

class cypherpunk.backend.api.v0.account.confirm.email extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	getVars: () =>
		@database = @server.root.api.user.database
		@schema = @database.schema
		@dataKey = @schema.dataKey
		@confirmedKey = @schema.confirmedKey

	# public account email verification api
	handler: (req, res) =>
		return res.send 400, 'missing parameters' unless (req.body?.accountId? and req.body?.confirmationToken?)
		accountId = req.body.accountId
		confirmationToken = req.body.confirmationToken

		return res.send 400, 'missing or invalid accountId' unless wiz.framework.util.strval.alphanumeric_valid(accountId)
		return res.send 400, 'missing or invalid confirmationToken' unless wiz.framework.util.strval.alphanumeric_valid(confirmationToken)

		wiz.log.debug 'accountId is '+accountId
		wiz.log.debug 'confirmationToken is '+confirmationToken

		@server.root.api.user.database.findOneByID req, res, accountId, (req2, res22, user) =>
			return res.send 404 unless (user?.confirmationToken? and typeof user.confirmationToken is "string")
			return res.send 404 unless (user.confirmationToken.length > 1 && confirmationToken == user.confirmationToken)

			# mark as confirmed
			@getVars()
			user[@dataKey][@confirmedKey] = true

			# update user object in database
			@server.root.api.user.database.updateUserData req, res, accountId, user[@dataKey], (result) =>
				return res.send 500, 'Unable to confirm account' if not result?

				# update radius database
				@server.root.api.radius.database.updateUserAccess req, res, user, (err) =>
					if err
						wiz.log.err(err)
						return res.send 500, 'Unable to grant access'

					# start new session for confirmed user
					out = @server.root.account.doUserLogin(req, res, user)
					res.send 200, out

class cypherpunk.backend.api.v0.account.confirm.resource extends cypherpunk.backend.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	load: () =>
		# inherit
		super()

		# public account creation api
		@routeAdd new cypherpunk.backend.api.v0.account.confirm.email(@server, this, 'email', 'POST')

# vim: foldmethod=marker wrap
