# copyright J. Maurice <j@wiz.biz>

wiz.package 'wiz.portal.userjs.table'

class wiz.portal.userjs.table.multiMulti extends wiz.portal.userjs.table.multi

	initTableAll: () => # {{{
		if @data.recordTypes
			for t of @data.recordTypes
				@initTableOne @data.recordTypes[t]
	#}}}
	initTableContainer: (t) => # {{{
		super t
		t.table
		.attr('id', 'table_'+t.type)
		.attr('recordType', t.type)
		t.container
		.append(
			$('<br><br>')
		)
	#}}}
	initTableHeadStrings: (t) => # {{{
		for d of t.data when datum = t.data[d]
			t.tableHeadRow.append(
				th = $('<th>')
					.text(datum.label)
			)
	#}}}

# vim: foldmethod=marker wrap
