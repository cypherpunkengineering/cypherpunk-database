# copyright J. Maurice <j@wiz.biz>

wiz.package 'wiz.portal.userjs.table'

class wiz.portal.userjs.table.multi extends wiz.portal.userjs.table.base

	insertDialogFormSelectCreate: (data) => #{{{
		@insertDialogFormSelect = $('<select>')
			.attr('id', 'insertSelect')
			.attr('name', 'insertSelect')
			.change (e) =>
				return if !@insertDialog

				@insertDialogFormFieldsCreate()

		# add a "Select..." entry at the top
		@insertDialogFormSelect
		.append(
			$('<option>')
			.attr('value', -1)
			.text(@stringSelectListingType)
		)

		# insert an option for each valid record type

		for t of @data.recordTypes
			recordType = @data.recordTypes[t]
			$(@insertDialogFormSelect)
			.append(
				$('<option>')
				.attr('value', recordType.type)
				.attr('selected', (data?.type == recordType.type || Object.keys(this.data.recordTypes).length == 1))
				.text(recordType.description)
			)
	#}}}
	insertDialogFormFieldsCreateAll: (record) => #{{{
		# dont proceed until something is selected
		return if !@insertDialogFormSelect or $(@insertDialogFormSelect).find('option').length < 1

		# get options and selection from pull-down box
		options = @insertDialogFormSelect.find('option')
		selected = @insertDialogFormSelect.find('option:selected')
		selection = null
		# get selection if any
		if selected && selected.length > 0 && selected[0].value != -1
			selection = selected[0].value
		else # nothing selected
			return

		# get recordType object from selection
		recordType = null
		for t of @data.recordTypes
			if t == selection
				recordType = @data.recordTypes[t]
				break
		return unless recordType # not found

		for d of recordType.data when schema = $.extend {}, recordType.data[d]
			@insertDialogFormFieldsCreateOne(d, schema, record)
	#}}}

	tablesReload: () => #{{{
		for t of @data.recordTypes when type = @data.recordTypes[t]
			type.dt.fnDraw()
	#}}}

# vim: foldmethod=marker wrap
