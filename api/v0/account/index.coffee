# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/account/session'
require './_framework/http/db/mongo'

require '../../../db/customer'

require './register'
require './confirm'

wiz.package 'cypherpunk.backend.api.v0.account'

class cypherpunk.backend.api.v0.account.module extends wiz.framework.http.account.module
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	database: null

	load: () => #{{{
		super()

		# public account creation api
		@routeAdd new cypherpunk.backend.api.v0.account.register.resource(@server, this, 'register')
		# public account confirmation api
		@routeAdd new cypherpunk.backend.api.v0.account.confirm.resource(@server, this, 'confirm')
	#}}}
	init: () => #{{{
		@database = new cypherpunk.backend.db.customer(@server, this, @parent.parent.cypherpunkDB)
		super()
	#}}}

	sendWelcomeMail: (customer, cb) => #{{{
		if not customer?.data?.email?
			wiz.log.err 'no customer email!!'
			return

		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "welcome@cypherpunk.com"
			personalizations: [
				{
					to: [
						{
							email: customer.data.email
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
					value: 'Please confirm your account: '+@generateConfirmationURL(customer)
				}
			]

		@sendMail(mailData, cb)
	#}}}
	sendPurchaseMail: (customer, cb) => #{{{
		if not customer?.data?.email?
			wiz.log.err 'no customer email!!'
			return
		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "welcome@cypherpunk.com"
			personalizations: [
				{
					to: [
						{
							email: customer.data.email
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
	sendUpgradeMail: (customer, cb) => #{{{
		if not customer?.data?.email?
			wiz.log.err 'no customer email!!'
			return
		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "welcome@cypherpunk.com"
			personalizations: [
				{
					to: [
						{
							email: customer.data.email
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
	generateConfirmationURL: (customer) => #{{{
		"https://cypherpunk.engineering/confirmation/#{customer.id}?confirmationToken=#{customer.confirmationToken}"
	#}}}

# vim: foldmethod=marker wrap
