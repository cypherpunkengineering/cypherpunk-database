# copyright J. Maurice <j@wiz.biz>

wiz.package 'cypherpunk.backend.userjs.sessionManager'

class cypherpunk.backend.userjs.sessionManager extends wiz.portal.userjs.session
	isLoginPage: false

	init: () =>
		@container = $('#loginContainer')
		@desktopLogout = $('#sessionDesktop')
		@desktopLogin = $('#sessionDesktop')
		@mobileLogout = $('#sessionMobileLogout')
		@mobileLogin = $('#sessionMobileLogin')
		@mobileLoginBtn = $('#sessionMobileLoginBtn')

		super()

		if wiz?.session?.acct? # user is logged in
			@enableLogout()
		else
			@enableLogin()

		@loginBox() if @isLoginPage

	loginBox: () =>
		if wiz.session?.acct? and wiz.getUrlVars().indexOf('for') == -1 # we think we're logged in and we're not in a redirect loop
			@onLoginCompleted('OK') # redirect
		else # show login box
			@container.append(@createLoginFormMain())

sessionManager = null
$(document).ready =>
	sessionManager = new cypherpunk.backend.userjs.sessionManager()
	sessionManager.init()

# vim: foldmethod=marker wrap
