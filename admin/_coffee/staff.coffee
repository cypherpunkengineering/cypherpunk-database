# copyright 2012 J. Maurice <j@wiz.biz>

wiz.package 'cypherpunk.backend.admin.userjs.manageStaff'

class cypherpunk.backend.admin.userjs.manageStaff.table extends wiz.portal.userjs.table.multiMulti

	urlBase: wiz.getParentURL(2) + '/api/staff'
	#{{{ strings
	stringNuggets: 'staffs'
	stringInsertButton: 'Add staff'
	stringInsertSubmit: 'Add staff'
	stringInsertRecordDialogTitle: 'Add staff'
	stringInsertRecordSelectLabel: 'staff type'
	stringUpdateButton: 'Manage Staff'
	stringDropButton: 'Drop staffs'
	stringDropSubmit: 'Drop staffs'
	stringDropRecordDialogTitle: 'Drop staff'
	stringSelectStaffType: 'select staff type...'
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

manageStaffTable = null
$(document).ready =>
	manageStaffTable = new cypherpunk.backend.admin.userjs.manageStaff.table()
	manageStaffTable.ajax 'GET', manageStaffTable.urlBase + '/types', null, (types) =>
		manageStaffTable.init(types)

# vim: foldmethod=marker wrap
