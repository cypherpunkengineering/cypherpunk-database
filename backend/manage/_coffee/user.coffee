# copyright 2012 J. Maurice <j@wiz.biz>

wiz.package 'cypherpunk.backend.admin.userjs.manageAccount'

class cypherpunk.backend.admin.userjs.manageAccount.table extends wiz.portal.userjs.table.multiMulti

	urlBase: wiz.getParentURL(2) + '/api/user'
	#{{{ strings
	stringNuggets: 'accounts'
	stringInsertButton: 'Create account'
	stringInsertSubmit: 'Create account'
	stringInsertRecordDialogTitle: 'Create account'
	stringInsertRecordSelectLabel: 'Account type'
	stringUpdateButton: 'Manage Account'
	stringUpdateSubmit: 'Modify Account'
	stringDangerZone: 'Danger Zone'
	stringRecoverSubmit: 'Send Recovery Email'
	stringRefundSubmit: 'Refund and Suspend Account'
	stringDropSubmit: 'Suspend Account'
	stringDropRecordDialogTitle: 'Drop account'
	stringSelectType: 'Select account type...'
	stringTitle: 'Manage Accounts'
	stringTableHeaders: [
		'Account Type'
		'E-Mail Address'
		'Last Logged In'
	]
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
	initParams: (t) => #{{{
		super t
		t.params.bPaginate = true
		t.params.sAjaxSource = @urlListBase + '/' + $(t.table).attr('recordType')
		t.params.fnRowCallback = (nRow, aData, iDisplayIndex, iDisplayIndexFull) =>
			console.log nRow
			# @baseParams.fnRowCallback(nRow, aData, iDisplayIndex, iDisplayIndexFull)
			row = $('td', nRow)
			row.each (i) =>
				switch i
					when 0
						$(row[i]).html('')
						$(row[i])
						.append(
							_this.button
								classes: [ 'btn-primary' ]
								text: @stringUpdateButton
								click: @updateDialogOpen
						)
					when 3
						if aData[i] == 0
							ts = 'never'
						else
							ts = new Date(aData[i])
						$(row[i]).text(ts)
					else
						$(row[i])
						.text(aData[i])
		return t.params
	#}}}
	initTableToolbar: (t) => #{{{
		t.stringTableToolbarText = t.description + 's'
		super t
	#}}}
	insertDialogFormSelectCreate: (data) => #{{{
		super(data)
		@insertDialogFormSelect.attr('disabled', true) if data?
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

		if data
			@insertDialog = @modal
				id: @idInsertDialog
				classes: [ 'fade' ]
				label: @stringInsertRecordDialogTitle
				body: @insertDialogForm
				footer: $('<div>').append(
					$('<div>').append(
						@button
							classes: [ 'btn-primary' ]
							text: (if data then @stringUpdateSubmit else @stringInsertSubmit)
							click: @insertDialogFormSubmit
					)
					$('<hr>')
					$('<div>').append(
						@span
							text: @stringDangerZone
						@button
							classes: [ 'btn-danger' ]
							text: @stringDropSubmit
							click: @dropDialogFormSubmit
						@button
							classes: [ 'btn-danger' ]
							text: @stringRefundSubmit
							click: @dropDialogFormRefund
						@button
							classes: [ 'btn' ]
							text: @stringRecoverSubmit
							click: @insertDialogFormRecover
					)
				)
		else
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

	insertDialogFormRecover: (e) => #{{{

		e.preventDefault()
		return false if not @insertDialogForm

		recordToInsert = @insertDialogFormSerialize()
		return false if not recordToInsert or recordToInsert.length < 1

		if @insertDialog.attr('updateRecordID')
			@ajax 'POST', @urlUpdate + '/' + @insertDialog.attr('updateRecordID'), recordToInsert, @onDialogSubmitCompleted
		else
			@ajax 'POST', @urlInsert, recordToInsert, @onDialogSubmitCompleted

		return false
	#}}}

manageAccountTable = null
$(document).ready =>
	manageAccountTable = new cypherpunk.backend.admin.userjs.manageAccount.table()
	manageAccountTable.ajax 'GET', manageAccountTable.urlBase + '/types', null, (types) =>
		manageAccountTable.init(types)

# vim: foldmethod=marker wrap
