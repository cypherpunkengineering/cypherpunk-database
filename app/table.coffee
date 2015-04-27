# copyright J. Maurice <j@wiz.biz>

wiz.package 'wiz.portal.userjs.table'

class wiz.portal.userjs.table.base extends wiz.framework.app.base

	# array of table objects, defaults to one
	t: [{}]

	# settings {{{
	bodyToolbarButtons: true
	tableCheckmarkAppend: true
	idInsertDialog: 'insertDialog'
	idDropDialog: 'dropDialog'
	#}}}
	#{{{ strings

	stringNuggets: 'records'
	stringTitle: null
	stringExportData: 'Export Data'
	stringInsertButton: 'Add record'
	stringInsertRecordSelectLabel: null
	stringInsertSubmit: 'Add record'
	stringUpdateSubmit: 'Update record'
	stringUpdateButton: 'Update record'
	stringDropButton: 'Drop record'
	stringDropSubmit: 'Drop record'
	stringInsertRecordDialogTitle: 'Insert record'
	stringDropRecordDialogTitle: 'Drop record'
	stringTableToolbarText: null
	stringTableHeaders: [
		'Record Name'
		'Created On'
		'Last Updated'
	]
	stringBooleanEnabled: 'yes'
	stringBooleanDisabled: 'no'
	iconInsert: '/admin/_img/icons/32/record_insert.png'
	iconDrop: '/admin/_img/icons/32/record_drop.png'
	iconExport: '/admin/_img/icons/32/export_excel.png'
	#}}}
	#{{{ data
	insertDialogFormArgs: [
		{
			name: 'name'
			label: 'name'
			type: 'str'
		}
	]
	#}}}
	baseParams: #{{{
		aaSorting: []
		aoColumnDefs: [
			{
				'aTargets': [ '_all' ]
				'bSortable': false
			}
		]
		bFilter: false
		bInfo: true
		bJQueryUI: true
		bPaginate: true
		bProcessing: true
		bServerSide: true
		bStateSave: false # in big tables this creates too-long cookie length and breaks everything
		iDisplayLength: 10
		sAjaxSource: ''
		sDom: ''
		fnRowCallback: (nRow, aData, iDisplayIndex, iDisplayIndexFull) ->
			row = $('td', nRow)
			row.each (i) ->
				switch i
					when 0
						if aData.immutable
							$('td', nRow).first().html('\u2605')
						else
							$(row[i]).html(
								$('<input>')
								.attr('id', aData['DT_RowId'])
								.attr('type', 'checkbox')
								.addClass('recordCheckbox')
							)
		fnDrawCallback: () ->
			if @fnSettings().fnRecordsDisplay() > @fnSettings()._iDisplayLength
				$(this).parent().find('.dataTables_paginate').show()
				$(this).parent().find('.dataTables_filter').show()
				$(this).parent().find('.dataTables_length').show()
			else
				$(this).parent().find('.dataTables_paginate').hide()
				$(this).parent().find('.dataTables_filter').hide()
				if @fnSettings().fnRecordsDisplay() < 11
					$(this).parent().find('.dataTables_length').hide()

			return

#			if $.editable
#				$('td.canedit').editable wiz.getURL() + '/edit'
#					'height': '1em'
#					'callback' : (sValue, y) =>
#						$(this).fnDraw()
#					'submitdata' :  (value, settings) =>
#						alert('value: ' + value)
	#}}}

	tableCheckmark: () => #{{{
		tableCheckmark = $('<th>')
			.css('width', '35px')
			.append('<img src="/admin/_img/icons/checkmark.gif">')

		return tableCheckmark
	#}}}

	init: (@data) => #{{{
		#@urlBase ?= wiz.getParentURL() + '/api'
		@urlListBase ?= @urlBase + '/list'
		@urlFindOneByID ?= @urlBase + '/findOneByID'
		@urlList ?= @urlBase + '/list'
		@urlInsert ?= @urlBase + '/insert'
		@urlUpdate ?= @urlBase + '/update'
		@urlDrop ?= @urlBase + '/drop'
		@urlExport ?= @urlBase + '/export'

		@idBodyHeader = @container[0].id + 'Header'
		@idBodyToolbar = @container[0].id + 'Toolbar'
		@idBodySelector = @container[0].id + 'Selector'

		@initBaseParams()

		@initBodyHeader()
		@initTableAll()
	#}}}

	initBodyHeader: () => #{{{

		@container
		.append(
			@head = $('<div>')
			.attr('id', @idBodyHeader)
		)

		if @stringTitle
			@head
			.append(
				$('<h3>')
				.css('display', 'inline-block')
				.css('text-align', 'center')
				.text(@stringTitle)
			)

		if @idBodySelector
			@head
			.append(
				@selector = $('<div>')
				.css('display', 'inline-block')
				.css('padding-left', '9px')
				.attr('id', @idBodySelector)
			)

		if @bodyToolbarButtons
			@head
			.append(
				@toolbar = $('<div>')
				.attr('id', @idBodyToolbar)
			)
			@initBodyToolbar()
	#}}}
	initBodyToolbar: () => #{{{
		if @stringInsertButton
			@toolbarAction
				icon: @iconInsert
				click: @insertDialogOpen
				text: @stringInsertButton
		if @stringDropButton
			@toolbarAction
				icon: @iconDrop
				click: @dropDialogOpen
				text: @stringDropButton
		if @urlExport
			@toolbarAction
				icon: @iconExport
				href: @urlExport
				text: @stringExportData
	#}}}
	initBaseParams: () => #{{{
		@baseParams.sAjaxSource = @urlList
		@baseParams.oLanguage =
			sInfo: '_TOTAL_ '+@stringNuggets
			sInfoEmpty: 'no '+@stringNuggets
			sEmptyTable: 'no '+@stringNuggets

		# http://datatables.net/ref#sDom
		# <'row-fluid'<'span6'T><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>
		sDom = ''
		sDom += '<"row-fluid"'
		sDom +=		'<"span3"'
		if @baseParams.bPaginate
			sDom +=		'l'
		sDom +=		'>'
		sDom +=		'<"span4"f>'
		sDom +=		'<"span5"p>'
		sDom +=		'r'
		sDom +=	'>'
		sDom += 't'
		sDom += '<"row-fluid"'
		sDom +=		'<"span6"i>'
		sDom +=		'<"span6"p>'
		sDom += '>'
		@baseParams.sDom =  sDom
	#}}}

	initTableAll: () => #{{{
		@initTableOne t for t in @t
	#}}}
	initTableOne: (t) => #{{{
		t.container ?= @container

		t.container
		.append(
			t.tableToolbar = $('<div>')
			.attr('id', @idBodyToolbar)
		)

		@initTableToolbar t
		@initTableContainer t

		# create params for DT and call DT
		@initParams t
		@initTableDT t
	#}}}
	initTableContainer: (t) => #{{{
		t.container
		.append(
			t.table = $('<table>')
			.addClass('table')
			.addClass('display')
			.append(@initTableHead t)
			.append(@initTableBody t)
		)
	#}}}
	initTableHead: (t) => #{{{
		# create thead and tr
		t.tableHead = $('<thead>')
		.append(
			t.tableHeadRow = $('<tr>')
		)

		# optionally create checkbox in first column header
		if @tableCheckmarkAppend
			t.tableHeadRow
			.append(
				@tableCheckmark()
			)

		# allow easy override
		@initTableHeadStrings(t)

		return t.tableHead
	#}}}
	initTableHeadStrings: (t) => #{{{
		t.stringTableHeaders = @stringTableHeaders

		for header in t.stringTableHeaders
			t.tableHeadRow
			.append(
				$('<th>')
				.text(header)
			)
	#}}}
	initTableBody: (t) => #{{{
		t.tableBody = $('<tbody>')
		.append(
			$('<tr>')
			.append(
				$('<td colspan="99" class="dataTables_empty">')
			)
		)

		return t.tableBody
	#}}}

	initParams: (t) => #{{{
		t.params = $.extend {}, @baseParams
	#}}}
	initTableDT: (t) => #{{{
		t.dt = t.table.dataTable t.params
	#}}}
	initTableToolbar: (t) => #{{{
		t.stringTableToolbarText ?= @stringTableToolbarText

		if t.stringTableToolbarText
			t.tableToolbar
			.append(
				t.tableToolbarText = $('<h4>')
					.text(t.stringTableToolbarText)
			)
		else
			t.tableToolbar
			.append(
				$('<br>')
			)
	#}}}

	insertDialogOpen: (e, data) => #{{{
		return if @insertDialog # one dialog at a time
		@insertDialogFormSelectCreate(data)
		@insertDialogFormFieldsCreate(data)
		@insertDialogModal(e, data)
	#}}}
	insertDialogModal: (e, data) => #{{{
		@insertDialogForm = @form
			submit: @insertDialogFormSubmit
			nugget:
				@controlGroup
					inputLabel: @stringInsertRecordSelectLabel
					controls: @controls
						nugget: @insertDialogFormSelect

		if @insertDialogFormFields
			@insertDialogForm.append @insertDialogFormFields

		@insertDialog = @modal
			id: @idInsertDialog
			classes: [ 'fade' ]
			label: @stringInsertRecordDialogTitle
			body: @insertDialogForm
			footer: @button
				classes: [ 'btn-primary' ]
				text: (if data then @stringUpdateSubmit else @stringInsertSubmit)
				click: @insertDialogFormSubmit

		@setUpdateRecordID(data)

		@insertDialog.on 'hidden.bs.modal', () =>
			@insertDialog.remove()
			@insertDialog = null

		@insertDialog.modal()
	#}}}
	insertDialogFormSelectCreate: () => #{{{
		# implement in child class
	#}}}
	insertDialogFormFieldsCreate: (data) => #{{{
		@insertDialogFormFieldsCreateInit(data)
		@insertDialogFormFieldsCreateAll(data)
	#}}}
	insertDialogFormFieldsCreateInit: () => #{{{
		# save parent object if updating
		p = null
		if @insertDialogFormFields
			p = @insertDialogFormFields.parent()
			@insertDialogFormFields.remove() # nuke old form fields

		# start from scratch
		@insertDialogFormFields = $('<div class="form-group">')

		if (p) # append new object to parent
			$(p).append(@insertDialogFormFields)
	#}}}
	insertDialogFormFieldsCreateAll: (record) => #{{{
		for arg in @insertDialogFormArgs
			@insertDialogFormFieldsCreateOne(arg.id, arg, record)
	#}}}
	insertDialogFormFieldsCreateOne: (id, schema, record) => #{{{
		nugget = null

		switch schema.type
			when 'passwd'
				schema.input = 'password'

			when 'pulldown'
				schema.input = 'select'

			when 'multiSelect'
				schema.input = 'multiSelect'

			when 'boolean'
				schema.input = 'select'
				schema.selopts =
					on: @stringBooleanEnabled
					off: @stringBooleanDisabled

			when 'nugget'
				nugget = schema.nugget

			else
				schema.input = 'text'

		schema.value = record?.data?[id]

		controls = null
		if nugget
			controls = @controls
				nugget: nugget

		@insertDialogFormFieldsCreateOneControl(id, schema, controls)
	#}}}
	insertDialogFormFieldsCreateOneControl: (id, datum, controls) => #{{{
		@insertDialogFormFields
		.append(
			@controlGroup
				controls: controls
				inputID: "data[#{id}]"
				inputLabel: datum.label
				inputName: datum.name
				inputType: datum.input
				inputValue: datum.value
				inputArgType: datum.type
				inputPlaceholder: datum.placeholder
				inputSelopts: datum.selopts
				inputBlur: @formFieldValidate
		)
	#}}}
	insertDialogFormSubmit: (e) => #{{{

		e.preventDefault()
		return false if not @insertDialogForm

		recordToInsert = @insertDialogForm.serializeArray()
		return false if not recordToInsert or recordToInsert.length < 1

		if @insertDialog.attr('updateRecordID')
			@ajax 'POST', @urlUpdate + '/' + @insertDialog.attr('updateRecordID'), recordToInsert, @onDialogSubmitCompleted
		else
			@ajax 'POST', @urlInsert, recordToInsert, @onDialogSubmitCompleted

		return false
	#}}}
	setUpdateRecordID: (data) =>
		if data
			@insertDialog.attr('updateRecordID', data.id)
	updateDialogOpen: (e) => #{{{
		id = $(e.target.parentNode.parentNode).attr('id')
		@ajax 'GET', @urlFindOneByID + '/' + id, null, (data) =>
			@insertDialogOpen(e, data)
	#}}}

	dropDialogOpen: (e) => #{{{
		return if @dropDialog

		@dropArray = [] # array of ids to delete
		recordsTable = $('<table>') # table to display records to delete

		# find checked checkboxes in given table
		checkedBoxes = @container
		.find('table.dataTable')
		.find('td .recordCheckbox:checked')

		checkedBoxes
		.each (i) =>
			checkedBox = checkedBoxes[i]
			recordID = $(checkedBox).attr('id')
			@dropArray.push(recordID)

			record = $(checkedBox).parent().parent().find('td:eq(1)').text()

			recordsTable.append(
				$('<tr>')
				.append(
					$('<td>')
					.text(record)
				)
			)

		@dropDialog = @modal
			id: @idDropDialog
			classes: [ 'fade' ]
			label: @stringDropRecordDialogTitle
			body: recordsTable
			footer: @button
				classes: [ 'btn-danger' ]
				text: @stringDropSubmit
				click: @dropDialogFormSubmit

		@dropDialog.on 'hidden', () =>
			@dropDialog.remove()
			@dropDialog = null

		@dropDialog.modal()

	#}}}
	dropDialogFormSubmit: (e) => #{{{

		e.preventDefault()
		return false unless @dropDialog

		if @dropArray and @dropArray.length > 0
			dropData = @dropArray
		else if @dropData
			dropData = @dropData

		@ajax 'POST', @urlDrop, { recordsToDelete: dropData }, @onDialogSubmitCompleted

		return false
	#}}}

	formFieldValidate: (e) => #{{{
		t = e.target
		argtype = $(t).attr('argtype')
		valid = wiz.framework.util.strval.validate(argtype, t.value)
		@inputValidated(t, valid)
		return valid
	#}}}
	onDialogSubmitCompleted: () => #{{{
		@tablesReload()
		@dialogDestroy()
	#}}}
	dialogDestroy: () => #{{{
		if @insertDialog
			@insertDialog.modal('hide')
		else if @dropDialog
			@dropDialog.modal('hide')
	#}}}
	tablesReload: () => #{{{
		t.dt.fnDraw() if t.dt for t in @t
	#}}}

# vim: foldmethod=marker wrap
