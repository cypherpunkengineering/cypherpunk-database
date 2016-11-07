# copyright J. Maurice <j@wiz.biz>

wiz.package 'cypherpunk.backend.admin.userjs.myAccount'

class cypherpunk.backend.admin.userjs.myAccount extends wiz.framework.app.base

	idProfilePane: 'userProfile'
	idOtpPane: 'otpAuth'

	strProfilePane: 'User Profile'
	strOtpPane: 'Two-Factor Authentication'

	constructor: () ->
		super()
		@userProfile = new cypherpunk.backend.admin.userjs.userProfile()
		@otpAuth = new cypherpunk.backend.admin.userjs.otpAuth()

	init: () =>
		@container.append(
			@tabs(
				id: 'tabs'
				tabs: [
					@tabElement
						target: @idProfilePane
						text: @strProfilePane
#					@tabElement
#						classes: [ 'active' ]
#						target: @idOtpPane
#						text: @strOtpPane
				]
				panes: [
					@userProfile.container = @tabPane
						classes: [ 'in', 'active' ]
						id: @idProfilePane
#					@otpAuth.container = @tabPane
#						id: @idOtpPane
				]
			)
		)

		@userProfile.init()
#		@otpAuth.init()
#		@otpAuth.otpStatus()

$(document).ready =>
	myaccount = new cypherpunk.backend.admin.userjs.myAccount()
	myaccount.init()

# vim: foldmethod=marker wrap
