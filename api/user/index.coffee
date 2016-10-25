# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/acct/session'
require './_framework/http/db/mongo'

require '../../db/user'

wiz.package 'cypherpunk.backend.api.user'

class cypherpunk.backend.api.user.resource extends cypherpunk.backend.api.base
	database: null

	init: () => #{{{
		@database = new cypherpunk.backend.db.user(@server, this, @parent.wizDB)
		# api methods
		@routeAdd new cypherpunk.backend.api.user.types(@server, this, 'types')
		@routeAdd new cypherpunk.backend.api.user.list(@server, this, 'list')
		@routeAdd new cypherpunk.backend.api.user.findAll(@server, this, 'findAll')
		@routeAdd new cypherpunk.backend.api.user.findByType(@server, this, 'findByType')
		@routeAdd new cypherpunk.backend.api.user.findOneByID(@server, this, 'findOneByID')
		@routeAdd new cypherpunk.backend.api.user.insert(@server, this, 'insert', 'POST')
		@routeAdd new cypherpunk.backend.api.user.update(@server, this, 'update', 'POST')
		@routeAdd new cypherpunk.backend.api.user.myAccountPassword(@server, this, 'myAccountPassword', 'POST')
		@routeAdd new cypherpunk.backend.api.user.myAccountDetails(@server, this, 'myAccountDetails', 'POST')
		super()
	#}}}

	sendWelcomeMail: (user, cb) => #{{{
		if not user?.data?.email?
			wiz.log.err 'no user email!!'
			return

		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "welcome@cypherpunk.com"
			personalizations: [
				{
					to: [
						{
							email: user.data.email
						}
					]
					subject: 'Welcome to Cypherpunk Privacy'
				}
			]
			headers:
				'X-Accept-Language': 'en'
				'X-Mailer': 'CypherpunkPrivacyMail'
			content: [
				{
					type: 'text/plain'
					value: 'Please confirm your account: '+@generateConfirmationURL(user)
				}
			]

		@sendMail(mailData, cb)
	#}}}
	sendPurchaseMail: (user, cb) => #{{{
		if not user?.data?.email?
			wiz.log.err 'no user email!!'
			return
		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "welcome@cypherpunk.com"
			personalizations: [
				{
					to: [
						{
							email: user.data.email
						}
					]
					subject: "You've got Premium access to Cypherpunk Privacy"
				}
			]
			headers:
				'X-Accept-Language': 'en'
				'X-Mailer': 'CypherpunkPrivacyMail'
			content: [
				{
					type: 'text/plain'
					value: "You're premium! Thanks for purchasing"
				}
			]

		@sendMail(mailData, cb)
	#}}}
	sendUpgradeMail: (user, cb) => #{{{
		if not user?.data?.email?
			wiz.log.err 'no user email!!'
			return
		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "welcome@cypherpunk.com"
			personalizations: [
				{
					to: [
						{
							email: user.data.email
						}
					]
					subject: 'Your account has been upgraded'
				}
			]
			headers:
				'X-Accept-Language': 'en'
				'X-Mailer': 'CypherpunkPrivacyMail'
			content: [
				{
					type: 'text/plain'
					value: 'Please confirm your account'
				}
			]

		@sendMail(mailData, cb)
	#}}}
	sendMail: (mailData, cb) => #{{{
		if @debug
			console.log 'send mail to sendgrid:'
			console.log mailData
		@server.root.sendgrid.mail mailData, (error, response) =>
			if @debug
				console.log 'got callback from sendgrid:'
				console.log response.statusCode
				console.log response.headers
				console.log response.body
			if error
				console.log error
			cb()
	#}}}
	generateConfirmationURL: (user) => #{{{
		"https://cypherpunk.engineering/confirmation/#{user.id}?confirmationToken=#{user.confirmationToken}"
	#}}}

class cypherpunk.backend.api.user.types extends cypherpunk.backend.api.base
	handler: (req, res) => #{{{
		result = {}
		result.recordTypes = JSON.parse(JSON.stringify(@parent.database.schema.types))
		res.send 200, result
	#}}}
class cypherpunk.backend.api.user.findAll extends cypherpunk.backend.api.base
	handler: (req, res) => #{{{
		@parent.database.findAll(req, res)
	#}}}
class cypherpunk.backend.api.user.list extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.list(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.user.findByType extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findByType(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.user.findOneByID extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.findOneByID(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.user.insert extends cypherpunk.backend.api.base
	# XXX: add permissions
	handler: (req, res) => #{{{
		@parent.database.insert(req, res)
	#}}}
class cypherpunk.backend.api.user.update extends cypherpunk.backend.api.base
	catchall: (req, res, routeWord) => #{{{
		@parent.database.update(req, res, routeWord)
	#}}}
class cypherpunk.backend.api.user.myAccountPassword extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	handler: (req, res) => #{{{
		@parent.database.myAccountPassword(req, res)
	#}}}

class cypherpunk.backend.api.user.myAccountDetails extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.friend
	handler: (req, res) => #{{{
		@parent.database.myAccountDetails(req, res)
	#}}}

# vim: foldmethod=marker wrap
