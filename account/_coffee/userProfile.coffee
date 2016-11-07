# copyright J. Maurice <j@wiz.biz>

wiz.package 'cypherpunk.backend.admin.userjs.userProfile'

class cypherpunk.backend.admin.userjs.userProfile extends wiz.framework.app.base

	#{{{ strings
	stringAccountDetails: 'Account Details'
	stringChangePassword: 'Change Password'

	idAccountDetailsForm: 'changePasswordForm'

	idFullName: 'fullname'
	stringFullNameL: 'Full Name'
	stringFullNamePH: 'John Smith'

	idEmail: 'email'
	stringEmailL: 'Email Address'
	stringEmailPH: 'user@domain.tld'

	idChangePasswordForm: 'changePasswordForm'

	idPasswordOld: 'passwordOld'
	stringPasswordOldL: 'Old Password'

	idPasswordNew: 'password'
	stringPasswordNewL: 'New Password (must be 6 - 50 characters long)'

	idPasswordNew2: 'password2'
	stringPasswordNew2L: 'New Password (type again to confirm)'

	idAccountDetailsSubmit: 'btnAccountDetailsSubmit'
	stringAccountDetailsSubmit: 'Update Changes'

	idChangePasswordSubmit: 'btnChangePasswordSubmit'
	stringChangePasswordSubmit: 'Change Password'
	#}}}
	init: () => #{{{
		@urlChangePassword = sessionManager.urlBase + '/api/staff/myAccountPassword'
		@urlAccountDetails = sessionManager.urlBase + '/api/staff/myAccountDetails'
		@createAccountDetailsForm()
		@createChangePasswordForm()
	#}}}

	createAccountDetailsForm: () => #{{{
		@accountDetailsForm = @form
			classes: [ 'form-horizontal' ]
		.submit(@submitAccountDetailsForm)
		.append(
			@legend
				text: @stringAccountDetails
		)
		if wiz.session?.account?.fullname? then @accountDetailsForm.append(
			@controlGroup
				inputID: @idBraces(@dataContainer, @idFullName)
				inputType: 'text'
				inputValue: wiz.session?.account?.fullname
				inputLabel: @stringFullNameL
				inputPlaceholder: @stringFullNamePH
		)
		@accountDetailsForm.append(
			@controlGroup
				inputID: @idBraces(@dataContainer, @idEmail)
				inputType: 'text'
				inputValue: wiz.session?.account?.email
				inputLabel: @stringEmailL
				inputPlaceholder: @stringEmailPH
		)
		.append(
			$('<div>').addClass('form-actions')
			.append(
				@button
					classes: [ 'btn-primary' ]
					id: @idAccountDetailsSubmit
					text: @stringAccountDetailsSubmit
					click: @submitAccountDetailsForm
			)
		)
		@container.append(@accountDetailsForm)
	#}}}
	createChangePasswordForm: () => #{{{
		@container.append(
			@changePasswordForm = @form
				classes: [ 'form-horizontal' ]
			.submit(@submitChangePasswordForm)
			.append(
				@legend
					text: @stringChangePassword
			)
			.append(
				@controlGroup
					inputID: @idBraces(@dataContainer, @idPasswordOld)
					inputType: 'password'
					inputLabel: @stringPasswordOldL
			)
			.append(
				@controlGroup
					inputID: @idBraces(@dataContainer, @idPasswordNew)
					inputType: 'password'
					inputLabel: @stringPasswordNewL
			)
#			.append(
#				@controlGroup
#					inputID: @idPasswordNew2
#					inputType: 'password'
#					inputLabel: @stringPasswordNew2L
#			)
			.append(
				$('<div>').addClass('form-actions')
				.append(
					@button
						classes: [ 'btn-primary' ]
						id: @idChangePasswordSubmit
						text: @stringChangePasswordSubmit
						click: @submitChangePasswordForm
				)
			)
		)
	#}}}

	submitChangePasswordForm: (e) =>
		e.preventDefault()
		data = @changePasswordForm.serializeArray()
		@ajax 'POST', @urlChangePassword, data, @onSubmitCompleted

	submitAccountDetailsForm: (e) =>
		e.preventDefault()
		data = @accountDetailsForm.serializeArray()
		@ajax 'POST', @urlAccountDetails, data, @onSubmitCompleted

	onSubmitCompleted: (e) =>
		alert 'Success!'

# vim: foldmethod=marker wrap
