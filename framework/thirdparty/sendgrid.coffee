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
	mailSimple: (args, cb) => #{{{
		from = @address(args.from)
		to = @address(args.to)
		subject = @subject(args.subject)
		content = @content(args.content, args.contentType)
		mail = new (@helper.Mail)(from, subject, to, content)

		mailSend = @SendGrid.emptyRequest
			method: 'POST'
			path: '/v3/mail/send'
			body: mail.toJSON()

		@SendGrid.API(mailSend, cb)
	#}}}
	mailTemplate: (args, cb) => #{{{
		mailData =
			template_id: args?.template_id
			from:
				name: args?.from?.name
				email: args?.from?.email
			personalizations: [
				{
					to: [
						{
							email: args?.to?.email
						}
					]
					subject: args?.subject
					substitutions: args.substitutions
				}
			]
			headers:
				'X-Accept-Language': 'en'
				'X-Mailer': 'CypherpunkPrivacyMail'

		mailSend = @SendGrid.emptyRequest
			method: 'POST'
			path: '/v3/mail/send'
			body: mailData

		@SendGrid.API(mailSend, cb)
	#}}}
	mailFullExample: () => #{{{
		body =
			'asm': #{{{
				'group_id': 1
				'groups_to_display': [
					1
					2
					3
				]
			#}}}
			'attachments': [ { #{{{
				'content': '[BASE64 encoded content block here]'
				'content_id': 'ii_139db99fdb5c3704'
				'disposition': 'inline'
				'filename': 'file1.jpg'
				'name': 'file1'
				'type': 'jpg'
			} ] #}}}
			'batch_id': '[YOUR BATCH ID GOES HERE]'
			'categories': [ #{{{
				'category1'
				'category2'
			] #}}}
			'content': [ { #{{{
				'type': 'text/html'
				'value': '<html><p>Hello, world!</p><img src=[CID GOES HERE]></img></html>'
			} ] #}}}
			'custom_args': #{{{
				'New Argument 1': 'New Value 1'
				'activationAttempt': '1'
				'customerAccountNumber': '[CUSTOMER ACCOUNT NUMBER GOES HERE]'
			#}}}
			'from': #{{{
				'email': 'sam.smith@example.com'
				'name': 'Sam Smith'
			#}}}
			'headers': {}
			'ip_pool_name': '[YOUR POOL NAME GOES HERE]'
			'mail_settings': #{{{
				'bcc':
					'email': 'ben.doe@example.com'
					'enable': true
				'bypass_list_management': 'enable': true
				'footer':
					'enable': true
					'html': '<p>Thanks</br>The SendGrid Team</p>'
					'text': 'Thanks,/n The SendGrid Team'
				'sandbox_mode': 'enable': false
				'spam_check':
					'enable': true
					'post_to_url': 'http://example.com/compliance'
					'threshold': 3
			#}}}
			'personalizations': [ { #{{{
				'bcc': [ {
					'email': 'sam.doe@example.com'
					'name': 'Sam Doe'
				} ]
				'cc': [ {
					'email': 'jane.doe@example.com'
					'name': 'Jane Doe'
				} ]
				'custom_args':
					'New Argument 1': 'New Value 1'
					'activationAttempt': '1'
					'customerAccountNumber': '[CUSTOMER ACCOUNT NUMBER GOES HERE]'
				'headers':
					'X-Accept-Language': 'en'
					'X-Mailer': 'MyApp'
				'send_at': 1409348513
				'subject': 'Hello, World!'
				'substitutions':
					'id': 'substitutions'
					'type': 'object'
				'to': [ {
					'email': 'john.doe@example.com'
					'name': 'John Doe'
				} ]
			} ] #}}}
			'reply_to': #{{{
				'email': 'sam.smith@example.com'
				'name': 'Sam Smith'
			#}}}
			'sections': 'section': #{{{
				':sectionName1': 'section 1 text'
				':sectionName2': 'section 2 text'
			#}}}
			'send_at': 1409348513
			'subject': 'Hello, World!'
			'template_id': '[YOUR TEMPLATE ID GOES HERE]'
			'tracking_settings': #{{{
				'click_tracking':
					'enable': true
					'enable_text': true
				'ganalytics':
					'enable': true
					'utm_campaign': '[NAME OF YOUR REFERRER SOURCE]'
					'utm_content': '[USE THIS SPACE TO DIFFERENTIATE YOUR EMAIL FROM ADS]'
					'utm_medium': '[NAME OF YOUR MARKETING MEDIUM e.g. email]'
					'utm_name': '[NAME OF YOUR CAMPAIGN]'
					'utm_term': '[IDENTIFY PAID KEYWORDS HERE]'
				'open_tracking':
					'enable': true
					'substitution_tag': '%opentrack'
				'subscription_tracking':
					'enable': true
					'html': 'If you would like to unsubscribe and stop receiving these emails <% clickhere %>.'
					'substitution_tag': '<%click here%>'
					'text': 'If you would like to unsubscribe and stop receiveing these emails <% click here %>.'
			#}}}
	#}}}

	mail: (mail, cb) => #{{{
		mailSend = @SendGrid.emptyRequest
			method: 'POST'
			path: '/v3/mail/send'
			body: mail

		@SendGrid.API(mailSend, cb)
	#}}}

# vim: foldmethod=marker wrap
