# copyright 2012 J. Maurice <j@wiz.biz>

wiz.package 'cypherpunk.backend.billing.userjs.charge'

class cypherpunk.backend.billing.userjs.charge.table extends wiz.portal.userjs.table.multiMulti

	urlBase: wiz.getParentURL(2) + '/api/charge'
	#{{{ strings
	stringNuggets: 'charges'
	stringInsertButton: null
	stringInsertSubmit: 'View charge'
	stringInsertRecordDialogTitle: 'View charge'
	stringInsertRecordSelectLabel: 'charge type'
	stringUpdateButton: 'Manage Charge'
	stringDropButton: null
	stringDropSubmit: 'Drop charges'
	stringDropRecordDialogTitle: 'Drop charge'
	stringSelectType: 'select charge type...'
	stringTitle: null
	stringTableHeaders: [
		'E-Mail Address'
		'Payment Amount'
		'Payment Date'
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
					when 4
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

chargeTable = null
$(document).ready =>
	chargeTable = new cypherpunk.backend.billing.userjs.charge.table()
	chargeTable.ajax 'GET', chargeTable.urlBase + '/types', null, (types) =>
		chargeTable.init(types)

# vim: foldmethod=marker wrap
