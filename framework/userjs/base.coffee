# copyright 2015 J. Maurice <j@wiz.biz>

wiz.package 'wiz.framework.app.base'

class wiz.framework.app.base

	constructor: () ->
		@container = $('#wizBody1')
		@toolbar = $('#wizBody')

	dataContainer: 'data'
	idBraces: (ar, id) -> "#{ar}[#{id}]"

	init:() => #{{{
	#}}}

	ajaxReturnCodes: #{{{
		400: (jqXHR, textStatus, errorThrown) ->
			alert jqXHR.responseText ? errorThrown
		401: (jqXHR, textStatus, errorThrown) ->
			window.location.href = sessionManager.urlBase + '/login?for=' + escape(wiz.getURL())
		403: (jqXHR, textStatus, errorThrown) ->
			#alert('access denied')
			window.location.href = sessionManager.urlBase + '/login?for=' + escape(wiz.getURL())
		409: (jqXHR, textStatus, errorThrown) ->
			alert jqXHR.responseText ? errorThrown
	#}}}

	ajax: (type, url, data, success, error) => #{{{
		$.ajax
			type: type
			url: url
			data: data
			success: success
			error: error
			statusCode: @ajaxReturnCodes
	#}}}

	modal: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'modal'
		args.classes.push 'fade'
		args.id ?= ''
		args.body ?= $('<div>')
		args.footer ?= $('<div>')

		modalLabelID = args.id + 'Label'

		modal = $('<div>')
		modal.addClass(c) for c in args.classes
		modal.attr('id', args.id) if args.id
		modal.attr('tabindex', '-1')
		modal.attr('role', 'dialog')
		modal.attr('aria-hidden', 'true')
		modal.attr('aria-labelledby', modalLabelID)

		modal.append(
			modalDialog = $('<div>')
			.addClass('modal-dialog')
		)

		modalDialog.append(
			modalContent = $('<div>')
			.addClass('modal-content')
		)

		modalContent.append(
			$('<div>')
			.addClass('modal-header')
			.append(
				$('<button>')
				.addClass('close')
				.attr('data-dismiss', 'modal')
				.attr('aria-hidden', 'true')
			)
			.append(
				$('<h3>')
				.addClass('myModalLabel')
				.text(args.label)
				.attr('id', modalLabelID)
			)
		)

		# TODO: create modalBody
		modalContent.append(
			$('<div>')
			.addClass('modal-body')
			.append(args.body)
		)

		# TODO: create modalFooter
		modalContent.append(
			$('<div>')
			.addClass('modal-footer')
			.append(args.footer)
		)

		return modal
	#}}}

	form: (args) => #{{{
		args ?= {}
		args.classes ?= []

		form = $('<form>')
		form.addClass(c) for c in args.classes
		form.attr('id', args.id) if args.id
		form.append(args.nugget) if args.nugget
		form.submit(args.submit) if args.submit

		return form
	#}}}l

	legend: (args) => #{{{
		args ?= {}
		args.classes ?= []

		legend = $('<legend>')
		legend.addClass(c) for c in args.classes
		legend.attr('id', args.id) if args.id
		legend.append(args.icon) if args.icon
		legend.append(' ') if args.icon
		legend.append(args.text) if args.text
		legend.append(' ') if args.button
		legend.append(args.button) if args.button

		return legend
	#}}}

	controlGroup: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'control-group'
		args.inputLabel ?= ''

		controlGroup = $('<div>')

		controlGroup.addClass(c) for c in args.classes

		controlGroup.append(
			@controlLabel
				text: args.inputLabel
		)

		if args.controls
			controlGroup.append(args.controls)
		else
			controlGroup.append(
				@controls
					nugget:
						@input
							id: args.inputID
							name: args.inputID
							type: args.inputType
							disabled: args.inputDisabled
							argtype: args.inputArgType
							placeholder: args.inputPlaceholder
							value: args.inputValue
							blur: args.inputBlur
							selopts: args.inputSelopts
							inputArgs: args.inputArgs
			)

		return controlGroup
	#}}}

	controls: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'controls'

		controls = $('<div>')
		controls.addClass(c) for c in args.classes
		controls.append(args.nugget) if args.nugget

		return controls
	#}}}

	controlLabel: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'control-label'
		args.text ?= ''

		controlLabel = $('<label>')

		controlLabel.addClass(c) for c in args.classes
		controlLabel.text(args.text)

		return controlLabel
	#}}}

	input: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'form-control'
		args.type ?= 'text'

		# for pull-down box options
		# FIXME: move into separate method with separate args
		if (args.type == 'select' or args.type == 'multiSelect') and args.selopts

			input = $('<select>')
			if args.type == 'multiSelect'
				input.attr('multiple', 'multiple')
				cb = () =>
					input.multiselect
						maxHeight: 500
						includeSelectAllOption: true
						enableFiltering: true
						enableCaseInsensitiveFiltering: true
						enableClickableOptGroups: true
				setTimeout cb, 100
				# FIXME: there has to be an event we can listen for

			for k, v of args.selopts
				if typeof v is 'object'
					input.append(
						@selopt
							value: v.value
							text: v.text
							selected: v.selected
					)
				else
					input.append(
						@selopt
							value: k
							text: v
							selected: (k?.toString() == args?.value?.toString())
					)
		else if args.type == 'checkbox'

			input = $('<input>')
			input.attr('checked', true) if args.value is 'on' or args.value is 'true'

		else if args.type == 'image'

			input = $('<input>')
			args.type = 'file'
			args.accept = 'image/*'
			args.inputArgs ?=
				previewFileType: 'image'
			cb = () =>
				input.fileinput(args.inputArgs)
			setTimeout cb, 100
			# FIXME: there has to be an event we can listen for

		else

			input = $('<input>')

		input.addClass(c) for c in args.classes
		input.attr('type', args.type)
		input.attr('id', args.id) if args.id?
		input.attr('disabled', 'disabled') if args.disabled?
		input.attr('placeholder', args.placeholder) if args.placeholder?
		input.attr('autocomplete', 'off') unless args.autocomplete?
		input.attr('name', args.name) if args.name?
		input.attr('value', args.value) if args.value? and args.type isnt 'select'
		input.attr('argtype', args.argtype) if args.argtype
		input.attr('maxlength', args.maxlength) if args.maxlength?
		input.attr('accept', args.accept) if args.accept?
		input.css('width', args.width) if args.width?
		input.blur(args.blur) if args.blur?
		input.click(args.click) if args.click?

		return input
	#}}}

	selopt: (args) => #{{{
		input = $('<option>')
		input.attr('value', args.value) if args.value?
		input.attr('data-img-src', args.imgsrc) if args.imgsrc?
		input.text(args.text) if args.text?
		input.attr('selected', true) if args.selected
		return input
	#}}}

	inputCombined: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'input-append'

		inputCombined = $('<div>')
		inputCombined.addClass(c) for c in args.classes
		inputCombined.append(i) for i in args.inputs

		return inputCombined
	#}}}

	button: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'btn'
		args.text ?= 'click me'

		button = $('<a>')
		button.addClass(c) for c in args.classes
		button.attr('id', args.id) if args.id
		button.attr('href', '#')
		button.text(args.text)
		button.click(args.click) if args.click

		return button
	#}}}

	img: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.src ?= ''
		args.alt ?= ''

		img = $('<img>')
		img.addClass(c) for c in args.classes
		img.attr('id', args.id) if args.id
		img.attr('src', args.src)
		img.attr('alt', args.alt)
		img.css('width', args.width) if args.width
		img.css('height', args.height) if args.height
		img.load(args.load) if args.load
		img.click(args.click) if args.click

		return img
	#}}}

	span: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.text ?= ''

		span = $('<span>')
		span.attr('id', args.id) if args.id
		span.addClass(c) for c in args.classes
		span.attr('width', args.width) if args.width
		span.attr('height', args.height) if args.height
		span.text(args.text)

		return span
	#}}}

	toolbarAction: (args) => #{{{
		args ?= {}
		args.href ?= '#'
		args.classes ?= []
		args.classes.push 'fa'
		args.classes.push 'fa-2x'
		args.classes.push args.icon
		args.text ?= ''
		args.click ?= () -> true
		@toolbar
		.append(
			btn = $('<a>')
			.addClass('btn')
			.attr('href', args.href)
			.click(args.click)
		)

		btn
		.append(
			i = $('<i>')
		)
		i.addClass(c) for c in args.classes

		btn
		.append(' ')
		.append(
			$('<span></span>')
			.text(args.text)
		)
	#}}}

	carousel: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'carousel'
		args.classes.push 'slide'
		args.items ?= []

		carousel = $('<div>')
		carousel.attr('id', args.id) if args.id
		carousel.addClass(c) for c in args.classes
		carousel.css('width', args.width) if args.width
		carousel.css('height', args.height) if args.height

		carousel.append(
			carouselInner = $('<div>')
			.addClass('carousel-inner')
		)

		for item in args.items
			carouselInner.append(item)

		carousel.append(
			$('<a>')
			.addClass('carousel-control')
			.addClass('left')
			.attr('href', '#' + args.id)
			.attr('data-slide', 'prev')
			.append('&lsaquo;')
		)

		carousel.append(
			$('<a>')
			.addClass('carousel-control')
			.addClass('right')
			.attr('href', '#' + args.id)
			.attr('data-slide', 'next')
			.append('&rsaquo;')
		)

		carousel.carousel()

		return carousel
	#}}}

	carouselItem: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'item'
		args.items ?= []

		carouselItem = $('<div>')
		carouselItem.addClass(c) for c in args.classes
		carouselItem.attr('id', args.id) if args.id
		carouselItem.append(args.img)
		carouselItem.append(args.caption)
	#}}}

	carouselCaption: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'carousel-caption'
		args.items ?= []
		args.title ?= ''
		args.descr ?= ''

		carouselCaption = $('<div>')
		carouselCaption.addClass(c) for c in args.classes
		carouselCaption.attr('id', args.id) if args.id
		carouselCaption.append(
			$('<h4>')
			.text(args.title)
		)
		carouselCaption.append(
			$('<p>')
			.text(args.descr)
		)
	#}}}

	hero: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'hero-unit'

		hero = $('<div>')
		hero.attr('id', args.id) if args.id
		hero.addClass(c) for c in args.classes

		return hero
	#}}}

	thumbnail: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'thumbnail'
		args.text ?= ''

		thumbnail = $('<div>')
		thumbnail.attr('id', args.id) if args.id
		thumbnail.addClass(c) for c in args.classes
		thumbnail.append(args.thumb)
		thumbnail.append(args.caption)

		return thumbnail
	#}}}

	thumbnailLabel: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'caption'
		args.label ?= ''
		args.descr ?= ''
		args.actions ?= []

		caption = $('<div>')
		caption.attr('id', args.id) if args.id
		caption.addClass(c) for c in args.classes
		caption.append(args.label)
		caption.append(args.descr)
		caption.append(a) for a in args.actions

		return caption
	#}}}

	tabs: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.tabs ?= []
		args.panes ?= []

		tabs = $('<div>')
		.append(tabPanel = @tabPanel())
		.append(tabContent = @tabContent())

		tabPanel.append(tab) for tab in args.tabs
		tabContent.append(pane) for pane in args.panes

		return tabs
	#}}}

	tabPanel: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'nav'
		args.classes.push 'nav-tabs'

		tabPanel = $('<ul>')
		tabPanel.attr('id', args.id) if args.id
		tabPanel.addClass(c) for c in args.classes

		return tabPanel
	#}}}

	tabElement: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.target ?= ''
		args.text ?= ''

		tabElement = $('<li>')
		tabElement.attr('id', args.id) if args.id
		tabElement.addClass(c) for c in args.classes
		tabElement.append(
			$('<a>')
			.attr('href', '#' + args.target)
			.attr('data-toggle', 'tab')
			.text(args.text)
		)

		return tabElement
	#}}}

	tabContent: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'tab-content'

		tabContent = $('<div>')
		tabContent.attr('id', args.id) if args.id
		tabContent.addClass(c) for c in args.classes

		return tabContent
	#}}}

	tabPane: (args) => #{{{
		args ?= {}
		args.classes ?= []
		args.classes.push 'tab-pane'
		args.classes.push 'fade'

		tabPane = $('<div>')
		tabPane.attr('id', args.id) if args.id
		tabPane.addClass(c) for c in args.classes

		return tabPane
	#}}}

	inputValidated: (t, valid) => #{{{
		if controlGroup = $(t).parent().parent()
			if valid
				controlGroup.removeClass('error')
				controlGroup.addClass('success')
			else
				controlGroup.removeClass('success')
				controlGroup.addClass('error')
	#}}}

	displayAsUSD: (amount) => #{{{
		dollars = Math.floor(Math.abs(amount / 100))
		cents = ('00' + Math.abs(amount) % 100).slice(-2)
		usd = '$' + dollars + '.' + cents
		out = usd
		out = "(#{usd})" if amount < 0
		return out
	#}}}
	displayAsBTC: (amount) => #{{{
		# insert decimal point
		bitcoins = Math.floor(amount / 100000000)
		sats = ('00000000' + (amount % 100000000)).slice(-8)
		# trim trailing zeros
		float = parseFloat(bitcoins + '.' + sats)
		btcstr = +float.toFixed(8)
		# add bitcoin symbol
		btc = '\u0243'+btcstr
		return btc
	#}}}

# vim: foldmethod=marker wrap
