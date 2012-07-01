var chartStatsOverview = null
var chartStatsDetail = null
var chartStatsMarginLeft = 80;
var chartStatsMarginRight = 30;
var chartStatsDetailHeight = 500;

$(document).ready(function()
{

	chartStatsOverviewCreate = function(statsDataResponse)
	{
		var detailStart = statsDataResponse.statsDataStart;

		// calculate initial zoom area for detail chart
		var detailInitialDuration = statsDataResponse.statsDataDuration;
		if (statsDataResponse.statsDataType == 'hourly')
			detailInitialDuration = (1000 * 60 * 60 * 24 * 8);
		else if (statsDataResponse.statsDataType == 'daily')
			detailInitialDuration = (1000 * 60 * 60 * 24 * 200);

		// calculate offset for detail chart data
		var detailInitialDurationOverage = statsDataResponse.statsDataDuration - detailInitialDuration;
		if (detailInitialDurationOverage > 0)
			detailStart += detailInitialDurationOverage;

		// create smaller overview chart
		chartStatsOverview = new Highcharts.Chart
		(
			{
				chart: // {{{
				{
					renderTo: 'chartStatsOverviewDiv'
					,reflow: false
					,borderWidth: 0
					,backgroundColor: null
					,marginLeft: chartStatsMarginLeft
					,marginRight: chartStatsMarginRight
					,spacingRight: 20
					,zoomType: 'x'
					,animation:
					{
						duration: 1000
						,easing: 'easeOutBounce'
					}
					,events: // {{{
					{
						// listen to the selection event on the master chart to update the
						// extremes of the detail chart
						selection: function(event)
						{
							var extremesObject = event.xAxis[0];
							var min = extremesObject.min;
							var max = extremesObject.max;
							var detailData = [];
							var xAxis = this.xAxis[0];

							// reverse engineer the last part of the data
							jQuery.each(this.series[0].data, function(i, point)
								{
									if (point.x > min && point.x < max)
									{
										detailData.push(
											{
												x: point.x,
												y: point.y
											}
										);
									}
								}
							);

							// move the plot bands to reflect the new detail span
							xAxis.removePlotBand('mask-before');
							xAxis.addPlotBand
							(
								{
									id: 'mask-before',
									from: statsDataResponse.statsDataStart,
									to: min,
									color: Highcharts.theme.maskColor || 'rgba(0, 0, 0, 0.2)'
								}
							);

							xAxis.removePlotBand('mask-after');
							xAxis.addPlotBand
							(
								{
									id: 'mask-after',
									from: max,
									to: statsDataResponse.statsDataEnd,
									color: Highcharts.theme.maskColor || 'rgba(0, 0, 0, 0.2)'
								}
							);

							chartStatsDetail.series[0].setData(detailData);

							return false;
						}
					} // }}}
				}, // }}}
				title: // {{{
				{
						text: null
				}, // }}}
				xAxis: // {{{
				{
						type: 'datetime',
						showLastTickLabel: true,
						plotBands:
						[
							{
								id: 'mask-before',
								from: statsDataResponse.statsDataStart,
								to: detailStart,
								color: Highcharts.theme.maskColor || 'rgba(0, 0, 0, 0.2)'
							}
						],
						title:
						{
							text: null
						}
				}, // }}}
				yAxis: // {{{
				{
					title:
					{
						text: null
					},
					labels:
					{
						enabled: false
					},
					startOnTick: false,
					showFirstLabel: false,
					gridLineWidth: 0,
				}, // }}}
				tooltip: // {{{
				{
						formatter: function()
						{
							return false;
						}
				}, // }}}
				legend: // {{{
				{
					enabled: false
				}, // }}}
				credits: // {{{
				{
					enabled: false
				}, // }}}
				plotOptions: // {{{
				{
					series:
					{
						fillColor:
						{
							linearGradient: [0, 0, 0, 70],
							stops:
							[
								[0, highchartsOptions.colors[0]],
								[1, 'rgba(0,0,0,0)']
							]
						},
						lineWidth: 1,
						marker:
						{
							enabled: false
						},
						shadow: false,
						states:
						{
							hover:
							{
								lineWidth: 1
							}
						},
						enableMouseTracking: false
					}
				}, // }}}
				series: // {{{
				[
					{
						type: 'area',
						name: statsDataResponse.statsDataTitle,
						pointStart: statsDataResponse.statsDataStart,
						pointInterval: statsDataResponse.statsDataInterval,
						data: statsDataResponse.statsData
					}
				], //}}}
				exporting: // {{{
				{
					enabled: false
				} // }}}
			}
			,function(chartStatsOverview)
			{
				chartCreateStatsDetail(chartStatsOverview, statsDataResponse, detailStart)
			}
		);
	}

	chartCreateStatsDetail = function(chartStatsOverview, statsDataResponse, detailStart)
	{
		// create bigger detail chart
		var detailData = [];

		jQuery.each(chartStatsOverview.series[0].data, function(i, point)
			{
				if (point.x >= detailStart)
					detailData.push(point.y);
			}
		);

		// create a detail chart referenced by a global variable
		chartStatsDetail = new Highcharts.Chart
		(
			{
				chart: // {{{
				{
					renderTo: 'chartStatsDetailDiv',
					height: chartStatsDetailHeight,
					reflow: false,
					marginLeft: chartStatsMarginLeft,
					marginRight: chartStatsMarginRight,
					marginBottom: 120,
					style:
					{
						position: 'absolute'
					}
					,animation:
					{
						duration: 1000
						,easing: 'easeOutBounce'
					}
				} // }}}
				,credits: // {{{
				{
					enabled: false
				} // }}}
				,title: // {{{
				{
					text: statsDataResponse.statsDataTitle
				} // }}}
				,subtitle: // {{{
				{
					text: document.ontouchstart === undefined ?
						'Click and drag on the lower chart to zoom in' :
						'Drag your finger over the lower chart to zoom in'
				} // }}}
				,xAxis: // {{{
				{
					type: 'datetime',
					minRange: (statsDataResponse.statsDataInterval * 24),
				} // }}}
				,yAxis: // {{{
				{
					title:
					{
						text: statsDataResponse.statsDataLabel,
					}
				} // }}}
				,tooltip: // {{{
				{
					shared: true
				} // }}}
				,legend: // {{{
				{
					enabled: false
				} // }}}
				,plotOptions: // {{{
				{
					area:
					{
						fillColor:
						{
							linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1},
							stops:
							[
								[0, Highcharts.getOptions().colors[0]],
								[1, 'rgba(2,0,0,0)']
							]
						},
						lineWidth: 1,
						marker:
						{
							enabled: false,
							states:
							{
								hover:
								{
									enabled: true,
									radius: 5
								}
							}
						},
						shadow: false,
						states:
						{
							hover:
							{
								lineWidth: 1
							}
						}
					}
				} // }}}
				,series: // {{{
				[
					{
						type: 'area',
						name: statsDataResponse.statsDataTitle,
						pointStart: detailStart,
						pointInterval: statsDataResponse.statsDataInterval,
						data: detailData
					}
				] // }}}
				,exporting: // {{{
				{
					enabled: false
				} // }}}

		});
	}

	// make the container smaller and add a second container for the master chart
	var $container = $('#container')
			.css('position', 'relative');

	var $container2 = $('#container2')
			.css('position', 'relative');

	var $detailContainer = $('<div id="chartStatsDetailDiv">')
			.appendTo($container);

	var $masterContainer = $('<div id="chartStatsOverviewDiv">')
			.css({ position: 'absolute', top: chartStatsDetailHeight - 100, height: 80, width: '100%' })
			.appendTo($container);

	var ip = '0.0.0.0';
	var interval = 'hourly';

	chartStatsInit = function()
	{
		var statsURL = window.location.href + '/' + ip + '/' + interval;

		jQuery.getJSON(statsURL, null, function(statsDataResponse)
			{
				if (chartStatsOverview)
					chartStatsUpdate(statsDataResponse);
				else
					chartStatsOverviewCreate(statsDataResponse);
			}
		);
	}
	chartStatsInit();
	/*
	chartStatsUpdate = function(statsDataResponse)
	{
		chartStatsOverview.series[0].setData(statsDataResponse.statsData);
		chartStatsDetail.series[0].setData(statsDataResponse.statsData);
	}

	chartStatsButton = function()
	{
		if (interval == 'hourly')
			interval = 'daily';
		else if (interval == 'daily')
			interval = 'hourly';

		chartStatsInit();
	}

	var $button1 = $('<input type="button" value="button">')
			.appendTo($container2)
			.click(chartStatsButton);
	*/

});
