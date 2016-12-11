# copyright 2012 J. Maurice <j@wiz.biz>

wiz.package 'cypherpunk.backend.billing.userjs.billingSubscription'

class cypherpunk.backend.billing.userjs.billingSubscription.table extends wiz.portal.userjs.table.multiMulti

	urlBase: wiz.getParentURL(2) + '/api/subscription'
	#{{{ strings
	stringNuggets: 'subscriptions'
	stringInsertButton: null # 'Start subscription'
	stringInsertSubmit: 'Start subscription'
	stringInsertRecordDialogTitle: 'Start subscription'
	stringInsertRecordSelectLabel: 'subscription type'
	stringUpdateButton: 'Manage Subscription'
	stringDropButton: null # 'Cancel subscription'
	stringDropSubmit: 'Cancel subscription'
	stringDropRecordDialogTitle: 'Cancel subscription'
	stringSelectType: 'select subscription type...'
	stringTitle: null # 'Subscription Management'
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

billingSubscriptionTable = null
$(document).ready =>
	billingSubscriptionTable = new cypherpunk.backend.billing.userjs.billingSubscription.table()
	billingSubscriptionTable.ajax 'GET', billingSubscriptionTable.urlBase + '/types', null, (types) =>
		billingSubscriptionTable.init(types)

# vim: foldmethod=marker wrap
