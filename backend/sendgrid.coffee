require './_framework'
require './_framework/thirdparty/sendgrid'

wiz.package 'cypherpunk.backend.sendgrid'

class cypherpunk.backend.sendgrid extends wiz.framework.thirdparty.sendgrid
	sendTeaserMail: (user) => #{{{
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
			subject: 'Confirm your free preview invitation to Cypherpunk Privacy'
			template_id: '99f16955-a429-492b-8c45-5558d6c5b9a0'
			substitutions:
				'-titleText-': "You're only one step away"
				'-regularText-': "Click the button below to confirm your free preview invitation"
				'-buttonText-': "CONFIRM MY INVITATION"
				'-buttonURL-': @generateTeaserConfirmationURL(user)

		wiz.log.info "Sending teaser email to #{user.data.email}"
		@sendMail(mailData)
	#}}}
	sendTeaserShareWithFriendMail: (user) => #{{{
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
			template_id: '99f16955-a429-492b-8c45-5558d6c5b9a0'
			substitutions:
				'-titleText-': ""
				'-regularText-': "Click the button below to accept your early access invitation"
				'-buttonText-': "ACCEPT MY INVITATION"
				'-buttonURL-': @generateTeaserConfirmationURL(user)

		if user.referralName? and user.referralName.length > 0
			mailData.subject = "#{user.referralName} invited you to an early access preview of Cypherpunk Privacy"
			mailData.substitutions['-regularText-'] = "Click the button below to accept your early access invitation from #{user.referralName}"

		wiz.log.info "Sending invitation share with friends email to #{user.data.email}"
		@sendMail(mailData)
	#}}}

	sendWelcomeMail: (user) => #{{{
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
			template_id: '99f16955-a429-492b-8c45-5558d6c5b9a0'
			substitutions:
				'-titleText-': "You're only one step away"
				'-regularText-': "Click the button below to confirm your free trial to Cypherpunk Privacy"
				'-buttonText-': "ACTIVATE MY ACCOUNT"
				'-buttonURL-': @generateConfirmationURL(user)

		@mailTemplate mailData, (error, response) =>
			if @debug
				console.log 'got callback from sendgrid:'
				console.log response.statusCode
				console.log response.headers
				console.log response.body
			if error
				wiz.log.err "Unable to send email to #{user.data.email} due to sendgrid error" if sendgridError?
				console.log error?.response?.body?.errors

			wiz.log.info "Sent welcome email to #{user.data.email}"
	#}}}
	sendActivateInvitationMail: (user) => #{{{
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
			template_id: '99f16955-a429-492b-8c45-5558d6c5b9a0'
			substitutions:
				'-titleText-': "Here's your Free Preview access!"
				'-regularText-': "Click the button below to activate your account"
				'-buttonText-': "ACTIVATE MY ACCOUNT"
				'-buttonURL-': @generateActivateInvitationURL(user)

		@mailTemplate mailData, (error, response) =>
			if @debug
				console.log 'got callback from sendgrid:'
				console.log response.statusCode
				console.log response.headers
				console.log response.body
			if error
				wiz.log.err "Unable to send email to #{user.data.email} due to sendgrid error" if sendgridError?
				console.log error?.response?.body?.errors

			wiz.log.info "Sent welcome email to #{user.data.email}"
	#}}}
	sendChangeConfirmationMail: (user) => #{{{
		if not user?.pendingEmail?
			wiz.log.err 'no user pendingEmail!!'
			return

		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "hello@cypherpunk.com"
			to:
				email: user?.pendingEmail
			subject: 'Confirm your new email address'
			template_id: '99f16955-a429-492b-8c45-5558d6c5b9a0'
			substitutions:
				'-titleText-': "You're almost done..."
				'-regularText-': "Click the button below to confirm your new email address"
				'-buttonText-': "CONFIRM MY EMAIL"
				'-buttonURL-': @generateChangeConfirmationURL(user)

		@mailTemplate mailData, (error, response) =>
			if @debug
				console.log 'got callback from sendgrid:'
				console.log response.statusCode
				console.log response.headers
				console.log response.body
			if error
				wiz.log.err "Unable to send email to #{user.pendingEmail} due to sendgrid error" if sendgridError?
				console.log error?.response?.body?.errors

			wiz.log.info "Sent change confirmation email to #{user.pendingEmail}"
	#}}}
	sendAccountRecoveryMail: (user) => #{{{
		if not user?.data?.email?
			wiz.log.err 'no user pendingEmail!!'
			return

		mailData =
			from:
				name: "Cypherpunk Privacy"
				email: "hello@cypherpunk.com"
			to:
				email: user?.data?.email
			subject: 'Reset your password'
			template_id: '99f16955-a429-492b-8c45-5558d6c5b9a0'
			substitutions:
				'-titleText-': "Reset your account password"
				'-regularText-': "Click the button below to set your new account password"
				'-buttonText-': "RESET MY PASSWORD"
				'-buttonURL-': @generateAccountRecoveryURL(user)

		@mailTemplate mailData, (error, response) =>
			if @debug
				console.log 'got callback from sendgrid:'
				console.log response.statusCode
				console.log response.headers
				console.log response.body
			if error
				wiz.log.err "Unable to send email to #{user?.data?.email} due to sendgrid error" if sendgridError?
				console.log error?.response?.body?.errors

			wiz.log.info "Sent account recovery email to #{user?.data?.email}"
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
			cb() if cb?
	#}}}

	generateActivateInvitationURL: (user) => #{{{
		"https://cypherpunk.com/activate?accountId=#{user?.id}&recoveryToken=#{user?.recoveryToken}"
	#}}}
	generateConfirmationURL: (user) => #{{{
		"https://cypherpunk.com/confirm?accountId=#{user?.id}&confirmationToken=#{user?.confirmationToken}"
	#}}}
	generateChangeConfirmationURL: (user) => #{{{
		"https://cypherpunk.com/confirmChange?accountId=#{user?.id}&confirmationToken=#{user?.pendingEmailConfirmationToken}"
	#}}}
	generateAccountRecoveryURL: (user) => #{{{
		"https://cypherpunk.com/reset?accountId=#{user?.id}&recoveryToken=#{user?.recoveryToken}"
	#}}}
	generateTeaserConfirmationURL: (user) => #{{{
		"https://cypherpunk.com/confirmation?accountId=#{user?.id}&confirmationToken=#{user?.confirmationToken}"
	#}}}

# vim: foldmethod=marker wrap
