# copyright 2012 J. Maurice <j@wiz.biz>

wiz.package 'cypherpunk.backend.network.userjs.location'

class cypherpunk.backend.network.userjs.location.table extends wiz.portal.userjs.table.multiMulti

	urlBase: wiz.getParentURL(2) + '/api/network/location'
	#{{{ strings
	stringNuggets: 'locations'
	stringInsertButton: 'Add location'
	stringInsertSubmit: 'Add location'
	stringInsertRecordDialogTitle: 'Add location'
	stringInsertRecordSelectLabel: 'location type'
	stringUpdateButton: 'Manage User'
	stringDropButton: 'Drop locations'
	stringDropSubmit: 'Drop locations'
	stringDropRecordDialogTitle: 'Drop location'
	stringSelectType: 'select location type...'
	stringTitle: 'User Management'
	stringTableHeaders: [
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
					when 2
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

locationTable = null
$(document).ready =>
	locationTable = new cypherpunk.backend.network.userjs.location.table()
	locationTable.ajax 'GET', locationTable.urlBase + '/types', null, (types) =>
		locationTable.init(types)

# vim: foldmethod=marker wrap
