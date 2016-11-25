# copyright 2012 J. Maurice <j@wiz.biz>

wiz.package 'cypherpunk.backend.network.userjs.server'

class cypherpunk.backend.network.userjs.server.table extends wiz.portal.userjs.table.multiMulti

	urlBase: wiz.getParentURL(2) + '/api/network/server'
	#{{{ strings
	stringNuggets: 'servers'
	stringInsertButton: 'Add server'
	stringInsertSubmit: 'Add server'
	stringInsertRecordDialogTitle: 'Add server'
	stringInsertRecordSelectLabel: 'server type'
	stringUpdateButton: 'Manage User'
	stringDropButton: 'Drop servers'
	stringDropSubmit: 'Drop servers'
	stringDropRecordDialogTitle: 'Drop server'
	stringSelectUserType: 'select server type...'
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

serverTable = null
$(document).ready =>
	serverTable = new cypherpunk.backend.network.userjs.server.table()
	serverTable.ajax 'GET', serverTable.urlBase + '/types', null, (types) =>
		serverTable.init(types)

# vim: foldmethod=marker wrap
