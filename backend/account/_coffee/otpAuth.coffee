# copyright J. Maurice <j@wiz.biz>

wiz.package 'cypherpunk.backend.admin.userjs.otpAuth'

class cypherpunk.backend.admin.userjs.otpAuth extends wiz.framework.app.base

	urlStatus: wiz.getParentURL(1) + '/otpkeys/status'
	urlDisable: wiz.getParentURL(1) + '/otpkeys/disable'
	urlEnable: wiz.getParentURL(1) + '/otpkeys/enable'
	urlGenerate: wiz.getParentURL(1) + '/otpkeys/generate'

	otpStatusLegendID: 'otpStatus'
	otpStatusLegendLabel: 'OTP Configuration'

	otpSecretGenerateControlID: 'otpGenerateBtn'
	otpSecretGenerateControlLabel: 'Secret Key'
	otpSecretGenerateBtnID: 'otpGenerateBtn'
	otpSecretGenerateBtnLabel: 'Generate New'

	otpSecretQRcontrolID: 'otpSecretQRControl'
	otpSecretQRcontrolLabel: 'QR Code'

	otpSecret32ControlID: 'otpSecret32Control'
	otpSecret32ControlLabel: 'Base32'
	otpSecret32txtID: 'OTPsecret32'

	otpSecret16ControlID: 'otpSecret16Control'
	otpSecret16ControlLabel: 'Base16'
	otpSecret16txtID: 'OTPsecret16'

	otpCounter10ControlID: 'otpCounter10Control'
	otpCounter10ControlLabel: 'OTP Sequence'
	otpCounter10txtID: 'OTPcounter10'

	otpDisableControlID: 'otpDisableControl'
	otpDisableControlLabel: 'Disable OTP'
	otpDisableBtnID: 'otpDisableBtn'
	otpDisableBtnLabel: 'Disable OTP'

	otpEnableControlID: 'otpEnableControl'
	otpEnableControlLabel: 'OTP Status'
	otpEnableBtnID: 'otpEnableBtn'
	otpEnableBtnLabel: 'Enable'

	otpUserLegendID: 'userOTPlegend'
	otpUserLegendLabel: 'OTP Status'

	otpUserControlID: 'userOTPcontrol'
	otpUserControlLabel: 'Enter OTP code:'
	otpUserInputID: 'otpUserInput'
	otpUserInputPH: '???????'
	otpUserInputBtnID: 'otpUserInputBtn'
	otpUserInputBtnLabel: 'Enable'

	init: () =>

		@container.append(
			@form
				classes: [ 'form-horizontal' ]
			.submit( () -> false )
			.append(
				@legend
					icon: @img
						src: sessionManager.urlBase + '/_img/icons/32/key_go.png'
					text: @span
						text: @otpStatusLegendLabel
			)
			.append(
				@controlGroup
					inputID: @otpDisableControlID
					inputLabel: @otpDisableControlLabel
					classes: [ 'hidden' ]
					controls: @controls
						nugget:
							@btnDisable = @button
								id: @otpDisableBtnID
								text: @otpDisableBtnLabel
								click: @otpDisableOnClick
			)
			.append(
				@controlGroup
					inputID: @otpSecretGenerateControlID
					inputLabel: @otpSecretGenerateControlLabel
					controls: @controls
						nugget:
								@btnGenerate = @button
									id: @otpSecretGenerateBtnID
									text: @otpSecretGenerateBtnLabel
									click: @otpGenerateOnClick
			)
			.append(
				@controlGroup
					inputID: @otpSecretQRcontrolID
					inputLabel: @otpSecretQRcontrolLabel
					controls: @controls
						nugget:
								@qrcode = $('<div>').css('margin', '5px')
			)
			.append(
				@controlGroup
					inputID: @otpSecret32ControlID
					inputLabel: @otpSecret32ControlLabel
					controls: @controls
						nugget: @otpSecret32txt = @span
							id: @otpSecret32txtID
							text: '(not yet generated)'
			)
			.append(
				@controlGroup
					inputID: @otpSecret16ControlID
					inputLabel: @otpSecret16ControlLabel
					controls: @controls
						nugget: @otpSecret16txt = @span
							id: @otpSecret16txtID
							text: '(not yet generated)'
			)
			.append(
				@controlGroup
					inputID: @otpCounter10ControlID
					inputLabel: @otpCounter10ControlLabel
					controls: @controls
						nugget: @otpCounter10txt = @span
							id: @otpCounter10txtID
							text: '(not yet generated)'
			)
		)
		@container.append(
			@form
				classes: [ 'form-horizontal' ]
			.submit(@otpEnableOnClick)
			.append(
				@legend
					id: @otpUserLegendID
					icon: @img
						src: sessionManager.urlBase + '/_img/icons/32/application_key.png'
					text: @span
						text: @otpUserLegendLabel
					button:
						@btnStatus = @button
							classes: [ 'hidden' ]
							id: @otpStatusLegendID
			)
			.append(
				@controlGroup
					inputID: @otpUserControlID
					inputLabel: @otpUserControlLabel
					controls: @controls
						nugget: @inputCombined
							inputs: [

								@inputUser = @input
									id: @otpUserInputID
									placeholder: @otpUserInputPH

								@button
									classes: [ 'btn-primary' ]
									id: @otpUserInputBtnID
									text: @otpUserInputBtnLabel
									click: @otpEnableOnClick
							]
			)
		)

	otpStatus: () =>
		t = this
		@ajax 'GET', @urlStatus, null, (resp) ->
			if resp and resp.email and resp.otp

				if resp.otp.require
					t.btnStatus.removeClass 'hidden'
					t.btnStatus.removeClass 'btn-danger'
					t.btnStatus.addClass 'btn-success'
					t.btnStatus.text 'Enabled'
					t.btnDisable.removeClass 'hidden'
				else
					t.btnStatus.removeClass 'hidden'
					t.btnStatus.removeClass 'btn-success'
					t.btnStatus.addClass 'btn-danger'
					t.btnStatus.text 'Disabled'
					t.btnDisable.addClass 'hidden'

				if resp.otp.secret32
					otpuri = "otpauth://totp/#{resp.email}!#{window.location.hostname}?secret=#{resp.otp.secret32}"
					qr = new wiz.portal.userjs.qrcanvas
						text: otpuri
					t.qrcode.html(qr.render())
					t.qrcode.removeClass 'hidden'
					t.otpSecret32txt.text resp.otp.secret32
					t.otpSecret16txt.text resp.otp.secret16
					t.otpCounter10txt.text resp.otp.counter10
				else
					t.qrcode.addClass 'hidden'

	otpDisableOnClick: (e) =>
		t = this
		@ajax 'POST', @urlDisable, null, (resp) ->
			t.otpStatus()
		return false

	otpEnableOnClick: (e) =>
		t = this
		userotp = $(e.target.parentNode).find('input:text')[0].value
		@ajax 'POST', @urlEnable, { 'userotp' : userotp }, (resp) ->
			t.otpStatus()
		return false

	otpGenerateOnClick: () =>
		t = this
		@ajax 'POST', @urlGenerate, null, (resp) ->
			t.otpStatus()
		return false

# vim: foldmethod=marker wrap
