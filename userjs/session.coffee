# copyright J. Maurice <j@wiz.biz>

wiz.package 'wiz.portal.userjs.session'

class wiz.portal.userjs.session extends wiz.framework.app.base

	#{{{ containers
	desktopLogin: $('<div>')
	desktopLogout: $('<div>')
	mobileLogin: $('<div>')
	mobileLoginBtn:  $('<div>')
	mobileLogoutBtn:  $('<div>')
	#}}}
	#{{{ static constants

	idLogin: 'login'
	stringLogin: 'Login'
	stringLoginL: 'Email'
	stringLoginPH: 'user@example.com'

	idLogout: 'logout'
	stringLogoutL: 'Logout'

	idMyAccount: 'myAccount'
	stringMyAccount: 'My Account'

	idPassword: 'password'
	stringPasswordL: 'Password'
	stringPasswordPH: '********'

	idLeetcode: 'leetcode'
	stringOTPL: 'OTP Code'
	stringOTPPH: '123456'
	#}}}
	#{{{ state variables
	skeletonKeys: []
	#}}}

	init: () => #{{{
		@urlBase ?= ''
		@urlLoginCompleted ?= @urlBase + '/home'
		@urlLogoutCompleted ?= @urlBase + '/'
		@urlAuthenticateUserPW ?= @urlBase + '/account/authenticate/userpasswd'
		@urlAuthenticateYubiKeyHOTP ?= @urlBase + '/account/authenticate/yubikeyhotp'
		@urlLogout ?= @urlBase + '/account/logout'
		@urlLogin ?= @urlBase + '/account/login'
		@urlMyAccount ?= @urlBase + '/account/me'
		super()
	#}}}

	createLoginFormMain: () => #{{{
		return @createLoginFormUserPW()
		$('<div>')
		.append(
			$('<div>')
			.addClass('span12')
			.addClass('footer')
			.addClass('submitbtn')
			.append(
				@input
					type: 'submit'
					value: 'Login'
			)
		)
	#}}}
	createLoginFormUserPW: () => #{{{
		$('<form>')
		.addClass('form-signin')
		.submit(@doAuthenticateUserPW)
		.append(
			$('<div>')
			.addClass('span12')
			.addClass('footer')
			.append(
				$('<h1>')
				.addClass('form-signin-heading')
				.addClass('text-muted')
				.text('Sign In')
			)
			.append(
				@input
					id: @idLogin
					name: @idLogin
					classes: ['form-control']
					type: 'text'
					placeholder: @stringLoginL
					autocomplete: true
			)
			.append(' ')
			.append(' ')
			.append(
				@input
					id: @idPassword
					name: @idPassword
					classes: ['form-control']
					type: 'password'
					placeholder: @stringPasswordL
					autocomplete: true
			)
		)
		.append(
			$('<div>')
			.addClass('span12')
			.addClass('footer')
			.addClass('submitbtn')
			.append(
				@input
					classes: ['btn','btn-lg', 'btn-primary', 'btn-block']
					type: 'submit'
					value: 'Login'
			)
		)
	#}}}
	createLoginFormYubiKeyHOTP: () => #{{{
		$('<form>')
		.submit(@doAuthenticateYubiKeyHOTP)
		.append(
			$('<div>')
			.addClass('span12')
			.addClass('footer')
			.append(
				@img
					src: '_img/site/icon_otp.png'
					alt: 'otp icon'
			)
			.append(' ')
			.append(
				@input
					id: @idLeetcode
					name: @idLeetcode
					classes: [ 'otp' ]
					type: 'password'
					placeholder: @stringOTPL
			)
		)
		.append(
			$('<div>')
			.addClass('span12')
			.addClass('footer')
			.addClass('submitbtn')
			.append(
				@input
					type: 'submit'
					value: 'Login'
			)
		)
	#}}}
	createDropdownLoginForm: () => #{{{
		return $('<div>')
	#}}}

	enableLogin: () => #{{{
		@desktopLoginDropdown = $('<ul>')
		.addClass('dropdown-menu')
		.css('padding', '5px 10px 0px 10px')
		.append(@createDropdownLoginForm())

		@mobileLoginDropdown = $('<ul>')
		.addClass('dropdown-menu')
		.css('padding', '5px 10px 0px 10px')
		.append(@createDropdownLoginForm())

		# add login dropdown for desktop layout
		@desktopLogin
		.append(
			$('<a>')
			.attr('href', @urlLogin)
			.text(@stringLogin)
		)
		.append(
			@desktopLoginDropdown
		)

		# add login dropdown for mobile layout
		@mobileLogin
		.append(
			@mobileLoginDropdown
		)

		@mobileLoginBtn
		.text(@stringLoginL)
		.append(
			$('<b>')
			.addClass('caret')
		)
		@mobileLoginBtn.removeClass('hidden')
	#}}}
	logoutDropdown: () => #{{{
		return $('<ul>')
		.addClass('dropdown-menu')
		.append(
			$('<li>')
			.append(
				$('<a>')
				.attr('id', @idMyAccount)
				.attr('href', @urlMyAccount)
				.text(@stringMyAccount)
			)
		)
		.append(
			$('<li>')
			.append(
				$('<a>')
				.text(@stringLogoutL)
				.click(@doLogout)
			)
		)
	#}}}
	enableLogout: () => #{{{
		@desktopLogoutDropdown = @logoutDropdown()

		@desktopLogout
		.append(
			$('<a>')
			.addClass('dropdown-toggle')
			.attr('data-toggle', 'dropdown')
			.attr('href', '#')
			.text(wiz.session.acct.fullname)
			.append(
				$('<b>')
				.addClass('caret')
			)
		)
		.append(
			@desktopLogoutDropdown
		)

		@mobileLogoutDropdown = @logoutDropdown()
		@mobileLogout
		.append(@mobileLogoutDropdown)
	#}}}

	doAuthenticateUserPW: (e) => #{{{
		nuggets = $(e.target).serializeArray()
		@ajax 'POST', @urlAuthenticateUserPW, nuggets, @onAuthenticateUserPW
		return false
	#}}}
	onAuthenticateUserPW: (data, textStatus, jqXHR) => #{{{
		@onLoginSuccessful data
	#}}}

	doAuthenticateYubiKeyHOTP: (e) => #{{{
		nuggets = $(e.target).serializeArray()
		@ajax 'POST', @urlAuthenticateYubiKeyHOTP, nuggets, @onAuthenticateYubiKeyHOTP
		return false
	#}}}
	onAuthenticateYubiKeyHOTP: (session, textStatus, jqXHR) => #{{{
		@onLoginSuccessful session
	#}}}

	doAuthenticateTOTP: (e) => #{{{
		nuggets = $(e.target).serializeArray()
		@ajax 'POST', @urlAuthenticateTOTP, nuggets, @onAuthenticateTOTP
		return false
	#}}}
	onAuthenticateTOTP: (data, textStatus, jqXHR) => #{{{
		alert(data)
		@onLoginSuccessful data
	#}}}

	onLoginSuccessful: (data) => #{{{
		if not data or not data.secret or not data.acct
			return alert 'Error: invalid authentication response received'

		# save acct data in global wiz object
		wiz.session.acct = data.acct
		wiz.sessionSave()

		#
		# @showUserBox(wiz.session.acct)

		# proceed to next page
		@onLoginCompleted()
	#}}}
	onLoginCompleted: () => #{{{
		# redirect to user home page
		dst = @urlLoginCompleted

		# unless URL has a special page to redirect them to
		if loginFor = wiz.getUrlVar 'for'
			dst = unescape(loginFor)

		# set window location to redirect url
		window.location.href = dst
	#}}}

	doLogout: (e) => #{{{
		nuggets = {}
		@ajax 'POST', @urlLogout, nuggets, @onLogoutResponse
		return false
	#}}}
	onLogoutResponse: (data, textStatus, jqXHR) => #{{{
		if data == 'OK'
			wiz.sessionDestroy()
			window.location.href = '/'
	#}}}

# vim: foldmethod=marker wrap
