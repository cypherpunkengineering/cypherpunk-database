$(document).ready(function()
	{
		var nTable = $('#networkTable').dataTable(
			{
				'bProcessing': true
				,'bStateSave': true
				,'bServerSide': true
				,'aLengthMenu': [[25, 50, 100], [25, 50, 100]]
				,'iDisplayLength' : 25
				,'aoColumnDefs' :
				[
					{
						'aTargets': [ 2 ]
						,'bSortable' : false
						,'sClass': 'canedit'
					}
				]
				,'sAjaxSource': window.location.href + '/list'
				,'fnDrawCallback': function ()
				{
					$('#networkTable tbody td.canedit').editable(window.location.href + '/modify',
						{
							'height': '14px'
							,'callback' : function(sValue, y)
							{
								var aPos = nTable.fnGetPosition(this);
								nTable.fnUpdate(sValue, aPos[0], aPos[1]);
								nTable.fnDraw(); // Redraw the table from the new data on the server
							}
							,'submitdata' : function (value, settings)
							{
								return {
									'row_id' : this.parentNode.getAttribute('id')
									,'column' : nTable.fnGetPosition( this )[2]
								};
							}
						}
					);
				}
			}
		);

		/*
		$('#networkTable tbody tr').live('click', function()
			{
				var id = this.id;
				alert('you clicked '+id);
			}
		);
		*/
	}
);
