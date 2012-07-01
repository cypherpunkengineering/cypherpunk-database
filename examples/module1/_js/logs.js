$(document).ready(function()
	{
		logTable = $('#logTable').dataTable(
			{
				'bProcessing': true
				,'bStateSave': true
				,'bAutoWidth': false
				,'bServerSide': true
				,'aLengthMenu': [[25, 50, 100], [25, 50, 100]]
				,'iDisplayLength' : 25
				,'sPaginationType': 'full_numbers'
				,'sAjaxSource': window.location.href + '/logdata'
			}
		);

		$.ajax(
			{
				type: 'GET',
				async: false,
				url: window.location.href + '/distinctip',
				success: function(data)
				{
					var sel = document.createElement('select');
					sel.id = 'logTableFilterIP';
					seldef = document.createElement('option');
					seldef.value = '';
					seldef.innerHTML = 'All hosts';
					sel.appendChild(seldef);

					for (i = 0; i < data.length; i++)
					{
						var opt = document.createElement('option');
						opt.value = data[i];
						opt.innerHTML = data[i];
						sel.appendChild(opt);
					}

					var filter = document.getElementsByClassName('dataTables_filter');
					if (filter && filter.length > 0)
					{
						filter[0].innerHTML = 'Filter by Relay Host: ';
						filter[0].appendChild(sel);
					}

					$(sel).change(function()
						{
							logTable.fnFilter(this.value);
						}
					);
				}
			}
		);
	}
);
