require './_framework'

wiz.package 'cypherpunk.backend.sendgrid'

class cypherpunk.backend.sendgrid extends wiz.framework.thirdparty.sendgrid
	sendTeaserMail: (user, cb) => #{{{
		if not user?.data?.email?
			wiz.log.err 'no user email!!'
			return

		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "hello@cypherpunk.com"
			to:
				email: user?.data?.email
			#subject: 'Welcome to Cypherpunk Privacy'
			subject: 'Confirm your early access invitation to Cypherpunk Privacy'
			template_id: '99f16955-a429-492b-8c45-5558d6c5b9a0'
			substitutions:
				'-confirmUrl-': @generateTeaserConfirmationURL(user)

		@mailTemplate mailData, (error, response) =>
			if @debug
				console.log 'got callback from sendgrid:'
				console.log response.statusCode
				console.log response.headers
				console.log response.body
			if error
				console.log error?.response?.body?.errors
			cb()
	#}}}
	sendTeaserShareWithFriendMail: (user, referrerName, cb) => #{{{
		if not user?.data?.email?
			wiz.log.err 'no user email!!'
			return

		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "hello@cypherpunk.com"
			to:
				email: user?.data?.email
			#subject: 'Welcome to Cypherpunk Privacy'
			subject: referrerName + ' invited you to an early access preview of Cypherpunk Privacy'
			template_id: '18a34a5d-7770-4a22-ae23-9e1c14837552'
			substitutions:
				'-titleText-': "Click the button below to accept your early access invitation from #{referrerName}"
				'-confirmUrl-': @generateTeaserConfirmationURL(user)

		@mailTemplate mailData, (error, response) =>
			if @debug
				console.log 'got callback from sendgrid:'
				console.log response.statusCode
				console.log response.headers
				console.log response.body
			if error
				console.log error?.response?.body?.errors
			cb()
	#}}}
	sendTeaserShareWithFriendNoNameMail: (user, cb) => #{{{
		if not user?.data?.email?
			wiz.log.err 'no user email!!'
			return

		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "hello@cypherpunk.com"
			to:
				email: user?.data?.email
			#subject: 'Welcome to Cypherpunk Privacy'
			subject: "You've been invited to an early access preview of Cypherpunk Privacy"
			template_id: '18a34a5d-7770-4a22-ae23-9e1c14837552'
			substitutions:
				'-titleText-': "Click the button below to accept your early access invitation"
				'-confirmUrl-': @generateTeaserConfirmationURL(user)

		@mailTemplate mailData, (error, response) =>
			if @debug
				console.log 'got callback from sendgrid:'
				console.log response.statusCode
				console.log response.headers
				console.log response.body
			if error
				console.log error?.response?.body?.errors
			cb()
	#}}}

	sendWelcomeMail: (user, cb) => #{{{
		if not user?.data?.email?
			wiz.log.err 'no user email!!'
			return

		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "hello@cypherpunk.com"
			to:
				email: user?.data?.email
			#subject: 'Welcome to Cypherpunk Privacy'
			subject: 'Activate your account to get started with Cypherpunk Privacy'
			template_id: '23c0356b-cf75-470e-bced-82294688c5f7'
			substitutions:
				'-confirmUrl-': @generateConfirmationURL(user)

		@mailTemplate mailData, (error, response) =>
			if @debug
				console.log 'got callback from sendgrid:'
				console.log response.statusCode
				console.log response.headers
				console.log response.body
			if error
				console.log error?.response?.body?.errors
			cb()
	#}}}
	sendPurchaseMail: (user, cb) => #{{{
		if not user?.data?.email?
			wiz.log.err 'no user email!!'
			return

		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "support@cypherpunk.com"
			to:
				email: user?.data?.email
			subject: "You've got Premium Access to Cypherpunk Privacy"
			template_id: '43785435-e9cc-4eaf-b985-e104dcd56cb0'
			substitutions:
				'-userEmail-': user?.data?.email
				'-subscriptionPrice-': user?.data?.subscriptionPlan
				'-subscriptionRenewal-': user?.data?.subscriptionRenewal
				'-subscriptionExpiration-': user?.data?.subscriptionExpiration

		@sendMail(mailData, cb)
	#}}}
	sendUpgradeMail: (user, cb) => #{{{
		if not user?.data?.email?
			wiz.log.err 'no user email!!'
			return

		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "support@cypherpunk.com"
			to:
				email: user?.data?.email
			subject: "You've got Premium Access to Cypherpunk Privacy"
			template_id: '0971d5c3-5a69-40c0-b4db-54ce51acbfb4'
			substitutions:
				'-userEmail-': user?.data?.email
				'-subscriptionPrice-': user?.data?.subscriptionPlan
				'-subscriptionRenewal-': user?.data?.subscriptionRenewal
				'-subscriptionExpiration-': user?.data?.subscriptionExpiration

		wiz.log.info "Sending upgrade email to #{user.data.email}"
		@sendMail(mailData, cb)
	#}}}

	sendMail: (mailData, cb) => #{{{
		if @debug
			console.log 'send mail to sendgrid:'
			console.log mailData
		@mailTemplate mailData, (error, response) =>
			if @debug
				console.log 'got callback from sendgrid:'
				console.log response.statusCode
				console.log response.headers
				console.log response.body
			if error
				console.log error?.response?.body?.errors
			cb()
	#}}}

	generateConfirmationURL: (user) => #{{{
		"https://cypherpunk.com/confirm?accountId=#{user?.id}&confirmationToken=#{user?.confirmationToken}"
	#}}}
	generateTeaserConfirmationURL: (user) => #{{{
		"https://cypherpunk.com/confirmation?accountId=#{user?.id}&confirmationToken=#{user?.confirmationToken}"
	#}}}

# vim: foldmethod=marker wrap
