wiz.package 'cypherpunk.backend.admin.userjs.card'

class cypherpunk.backend.admin.userjs.card extends wiz.framework.app.base
	PublishableKey: 'pk_test_V8lLSY93CP6w9SFgqCmw8FUg' # Replace with your API publishable key
	paymentForm: null


	init: () =>
		@paymentForm = $('#payment-form')
		#@paymentForm.find('[type=submit]').prop 'disabled', true
		@paymentForm.on 'submit', @payWithStripe

	payWithStripe: (e) =>
		e.preventDefault()

		@paymentForm.find('[type=submit]').html 'Validating <i class="fa fa-spinner fa-pulse"></i>'
		Stripe.setPublishableKey @PublishableKey
		Stripe.card.createToken @paymentForm, (status, response) =>
			console.log response
			if response.error

				### Visual feedback ###

				@paymentForm.find('[type=submit]').html 'Try again'

				### Show Stripe errors on the form ###

				@paymentForm.find('.payment-errors').text response.error.message
				@paymentForm.find('.payment-errors').closest('.row').show()
			else

				### Visual feedback ###

				@paymentForm.find('[type=submit]').html 'Processing <i class="fa fa-spinner fa-pulse"></i>'

				### Hide Stripe errors on the form ###

				@paymentForm.find('.payment-errors').closest('.row').hide()
				@paymentForm.find('.payment-errors').text ''
				# response contains id and card, which contains additional card details
				token = response.id
				console.log token
				# AJAX
				$.post('/subscribe', stripeToken: token).done((data, textStatus, jqXHR) ->
					@paymentForm.find('[type=submit]').html('Payment successful <i class="fa fa-check"></i>').prop 'disabled', true
					return
				).fail (jqXHR, textStatus, errorThrown) ->
					@paymentForm.find('[type=submit]').html('There was a problem').removeClass('success').addClass 'error'

					### Show Stripe errors on the form ###

					@paymentForm.find('.payment-errors').text 'Try refreshing the page and trying again.'
					@paymentForm.find('.payment-errors').closest('.row').show()
					return
			return

		jQuery.validator.addMethod 'month', ((value, element) ->
			@optional(element) or /^(01|02|03|04|05|06|07|08|09|10|11|12)$/.test(value)
		), 'Please specify a valid 2-digit month.'
		jQuery.validator.addMethod 'year', ((value, element) ->
			@optional(element) or /^[0-9]{2}$/.test(value)
		), 'Please specify a valid 2-digit year.'
		jQuery.validator.addMethod 'exp', ((value, element) ->
			@optional(element) or /^(01|02|03|04|05|06|07|08|09|10|11|12) \/ [0-9]{2}$/.test(value)
		), 'Please specify a valid 2-digit month and year.'
		validator = @paymentForm.validate(
			rules:
				cardNumber:
					required: true
					creditcard: true
					digits: true
				exp:
					required: true
					month: true
					year: true
				cvc:
					required: true
					digits: true
			highlight: (element) ->
				$(element).closest('.form-control').removeClass('success').addClass 'error'
				return
			unhighlight: (element) ->
				$(element).closest('.form-control').removeClass('error').addClass 'success'
				return
			errorPlacement: (error, element) ->
				$(element).closest('.form-group').append error
				return
		)

	paymentFormReady: () =>
		if @paymentForm.find('[data-stripe=number]').hasClass('success') and @paymentForm.find('[data-stripe=exp]').hasClass('success') and @paymentForm.find('[data-stripe=cvc]').val().length > 1
			return true
		else
			return false

c = null
$(document).ready =>
	c = new cypherpunk.backend.admin.userjs.card()
	c.init()
	new Card
		form: '#payment-form'
		container: '.card-wrapper'

# vim: foldmethod=marker wrap
