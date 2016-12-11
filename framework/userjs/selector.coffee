# copyright J. Maurice <j@wiz.biz>

wiz.package 'wiz.portal.userjs.selector'

class wiz.portal.userjs.selector.base extends wiz.framework.app.base

	labelSelect: 'Selection'
	labelAll: 'All objects'
	urlChange: ''

	options: {}
	optionCount: 0
	optionAll: false

	constructor: () ->
		super()
		@container = $('#wizBody')

	setOptions: (options) =>
		options = {} if not options or typeof options is not 'object'
		@options = options
		@countOptions()

	countOptions: () =>
		@optionsCount = 0
		for o of @options
			@optionsCount += 1

	init: (options) =>
		@setOptions options

		@container.text(@labelSelect) if @labelSelect

		if @optionsCount >= 2

			@select = $('<select>')
			@select.change(@onChange)

			if @optionAll
				@select.append(
					$('<option>')
					.attr('value', 'ALL')
					.text(@labelAll)
				)

			for opt in @options
				o = $('<option>')
					.attr('value', opt.id)
					.text(opt.label)
				o.attr('selected', opt.selected) if opt.selected
				@select.append o

			@container.append(@select)

		else if @optionsCount == 1

			for opt in @options
				@container.append(
					$('<div>').text(opt.label)
				)

	onChange: (e) =>
		selected = e.target.value
		@ajax 'POST', @urlChange + "/#{selected}", null, @onChangeCompleted

	onChangeCompleted: () =>

# vim: foldmethod=marker wrap
