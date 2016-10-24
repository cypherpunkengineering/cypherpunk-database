require '..'

wiz.package 'wiz.framework.thirdparty.sendgrid'

# using SendGrid's v3 Node.js library
# https://github.com/sendgrid/sendgrid-nodejs

class wiz.framework.thirdparty.sendgrid
	SendGrid: null

	constructor: (@options) -> #{{{
		@SendGrid = require('sendgrid')(@options.apiKey)
	#}}}
	init: () => #{{{
		@helper = require('sendgrid').mail
	#}}}
	getInstance: () => #{{{
		@Stripe
	#}}}

	address: (address) => #{{{
		return new (@helper.Email)(address)
	#}}}
	content: (content, contentType = 'text/plain') => #{{{
		return new (@helper.Content)(contentType, content)
	#}}}
	subject: (subject) => #{{{
		return subject
	#}}}
	mail: (args) => #{{{
		from = @address(args.from)
		to = @address(args.to)
		subject = @subject(args.subject)
		content = @content(args.content, args.contentType)
		mail = new (@helper.Mail)(from, subject, to, content)
		@request(mail)
	#}}}

	request: (mail, cb) => #{{{
		request = sg.emptyRequest
			method: 'POST'
			path: '/v3/mail/send'
			body: mail.toJSON()

		sg.API(request, cb)
	#}}}

# vim: foldmethod=marker wrap
