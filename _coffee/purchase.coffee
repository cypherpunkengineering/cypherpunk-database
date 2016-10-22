wiz.package 'cypherpunk.backend.account.userjs.purchase'

class cypherpunk.backend.account.userjs.purchase extends wiz.framework.app.base

payWithStripe = (e) ->
	e.preventDefault()

	$form.find('[type=submit]').html 'Validating <i class="fa fa-spinner fa-pulse"></i>'
	PublishableKey = 'pk_test_6pRNASCoBOKtIshFeQd4XMUh'
	Stripe.setPublishableKey PublishableKey
	Stripe.card.createToken $form, (status, response) ->
		console.log status
		if response.error

			### Visual feedback ###

			$form.find('[type=submit]').html 'Try again'

			### Show Stripe errors on the form ###

			$form.find('.payment-errors').text response.error.message
			$form.find('.payment-errors').closest('.row').show()
		else

			### Visual feedback ###

			$form.find('[type=submit]').html 'Processing <i class="fa fa-spinner fa-pulse"></i>'

			### Hide Stripe errors on the form ###

			$form.find('.payment-errors').closest('.row').hide()
			$form.find('.payment-errors').text ''
			# response contains id and card, which contains additional card details
			token = response.id
			console.log token
			# AJAX
			$.post('/account/stripe_card_token', token: token).done((data, textStatus, jqXHR) ->
				$form.find('[type=submit]').html('Payment successful <i class="fa fa-check"></i>').prop 'disabled', true
				return
			).fail (jqXHR, textStatus, errorThrown) ->
				$form.find('[type=submit]').html('There was a problem').removeClass('success').addClass 'error'

				### Show Stripe errors on the form ###

				$form.find('.payment-errors').text 'Try refreshing the page and trying again.'
				$form.find('.payment-errors').closest('.row').show()
				return
		return
	return

jQuery.validator.addMethod 'month', ((value, element) ->
	@optional(element) or /^(01|02|03|04|05|06|07|08|09|10|11|12)$/.test(value)
), 'Please specify a valid 2-digit month.'
jQuery.validator.addMethod 'year', ((value, element) ->
	@optional(element) or /^[0-9]{2}$/.test(value)
), 'Please specify a valid 2-digit year.'
validator = $form.validate(
	rules:
		cardNumber:
			required: true
			creditcard: true
			digits: true
		expMonth:
			required: true
			month: true
		expYear:
			required: true
			year: true
		cvCode:
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

$(document).ready =>

$form = $('#payment-form')

paymentFormReady = ->
	if $form.find('[name=cardNumber]').hasClass('success') and $form.find('[name=expMonth]').hasClass('success') and $form.find('[name=expYear]').hasClass('success') and $form.find('[name=cvCode]').val().length > 1
		true
	else
		false

$form.find('[type=submit]').prop 'disabled', true
readyInterval = setInterval((->
	if paymentFormReady()
		$form.find('[type=submit]').prop 'disabled', false
		clearInterval readyInterval
	return
), 250)
$form.on 'submit', payWithStripe


# vim: foldmethod=marker wrap
