# copyright 2012 J. Maurice <j@wiz.biz>

wiz.package 'cypherpunk.backend.manage.userjs.admin'

class cypherpunk.backend.manage.userjs.admin.table extends wiz.portal.userjs.table.multiMulti

	urlBase: wiz.getParentURL(2) + '/api/admin'
	#{{{ strings
	stringNuggets: 'administrators'
	stringInsertButton: 'Add admin'
	stringInsertSubmit: 'Add admin'
	stringInsertRecordDialogTitle: 'Add admin'
	stringInsertRecordSelectLabel: 'admin type'
	stringUpdateButton: 'Manage Staff'
	stringDropButton: 'Drop administrators'
	stringDropSubmit: 'Drop administrators'
	stringDropRecordDialogTitle: 'Drop admin'
	stringSelectStaffType: 'select admin type...'
	stringTitle: 'Staff Management'
	stringTableHeaders: [
		'Full Name'
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

adminTable = null
$(document).ready =>
	adminTable = new cypherpunk.backend.manage.userjs.admin.table()
	adminTable.ajax 'GET', adminTable.urlBase + '/types', null, (types) =>
		adminTable.init(types)

# vim: foldmethod=marker wrap
