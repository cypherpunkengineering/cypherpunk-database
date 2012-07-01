$(document).ready(function()
	{
		var nTable = $('#notificationTable').dataTable(
			{
				'bProcessing': true
				,'bStateSave': true
				,'bServerSide': true
				,'aLengthMenu': [[25, 50, 100], [25, 50, 100]]
				,'iDisplayLength' : 25
				,'sAjaxSource': window.location.href + '/list'
				,'fnDrawCallback': function ()
				{
					$('#notificationTable tbody td').editable(window.location.href + '/modify',
						{
							'height': '14px',
							'callback': function(sValue, y)
							{
								/* Redraw the table from the new data on the server */
								nTable.fnDraw();
							},
						}
					);
				}
			}
		);
	
		/*
		$('#notificationTable tbody tr').live('click', function()
			{
				var id = this.id;
				alert('you clicked '+id);
		    }
		);
		*/
	}
);
