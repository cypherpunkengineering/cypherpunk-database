# wiz-framework: J's HTML5/NodeJS web application framework
#
# Copyright 2012 J. Maurice <j@wiz.biz>
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of version 3 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# The GNU General Public License: http://www.gnu.org/licenses/
#

# wiz-framework
require '../..'
require '../../wizfrontend'
require '../../wizutil/wizstring'

# wizfrontend package
wizpackage 'wizportal'

class wizportal.module1

	#{{{ database config
	mysqlConfig :
		hostname : 'localhost'
		username : 'wizportal'
		password : '9n3bf93d'

	mongoConfig :
		hostname :'localhost'
		username : 'wizmail'
		password : 'd2jd592r'
		database : 'wizmail'

	mongoServerOptions :
	    auto_reconnect : true
	    poolSize : 2

	mongoDbOptions :
	    reaper : true
	#}}}

	constructor: (portal) ->
		@mysql = new wizfrontend.mysql(@mysqlConfig)
		@mongo = new wizfrontend.mongo(@mongoConfig, @mongoServerOptions, @mongoDbOptions)

		#{{{ MODULE /module1
		module1 = portal.module 'module1', 'Example Module'
		#}}}

		#{{{ RESOURCE /stats1
		stats = module1.resource '/stats1', 'Example Chart 1'
		#}}}
		#{{{ METHOD		GET		/
		stats.method 'https', 'get', '/', portal.middleware.baseSessionAuth(), (req, res) =>
			page = portal.pengiPage 'Example Chart 1', req
			page.pengiJS.push portal.core.js('jquery.min')
			page.pengiJS.push portal.core.js('highcharts')
			page.pengiJS.push portal.core.js('highcharts-grid')
			page.pengiJS.push module1.js('stats1')
			res.render 'stats', page
		#}}}
		#{{{ METHOD		GET		/:ip/:interval
		stats.method 'https', 'get', '/:ip/:interval', portal.middleware.baseSessionAuthDatatable(), (req, res) =>

			statsDataResponse = {}
			#{{{ statsDataResponse.statsData
			statsDataResponse.statsData = [ 0.945, 0.5292, 0.869, 0.5330, 0.949, 0.5142, 0.779, 0.898, 0.5281, 0.5336, 0.5151, 0.894, 0.903, 0.908, 0.808, 0.5067, 0.791, 0.937, 0.5454, 0.5228, 0.5487, 0.549, 0.897, 0.925, 0.611, 0.863, 0.925, 0.5305, 0.5171, 0.5348, 0.5407, 0.615, 0.5140, 0.775, 0.5446, 0.589, 0.5418, 0.724, 0.987, 0.5198, 0.559, 0.638, 0.592, 0.963, 0.5046, 0.901, 0.530, 0.5338, 0.5338, 0.5484, 0.5065, 0.5325, 0.532, 0.5463, 0.750, 0.644, 0.825, 0.5175, 0.5449, 0.5497, 0.5023, 0.5355, 0.612, 0.662, 0.630, 0.557, 0.752, 0.548, 0.782, 0.5239, 0.5247, 0.842, 0.5378, 0.5339, 0.5305, 0.924, 0.740, 0.5335, 0.761, 0.578, 0.5319, 0.5327, 0.5404, 0.5351, 0.5289, 0.653, 0.5496, 0.614, 0.5329, 0.5444, 0.610, 0.851, 0.5299, 0.722, 0.5014, 0.5430, 0.780, 0.5266, 0.5478, 0.5062, 0.5005, 0.5224, 0.5404, 0.882, 0.5063, 0.5209, 0.5306, 0.5304, 0.5043, 0.567, 0.5383, 0.861, 0.5394, 0.5286, 0.712, 0.5182, 0.5440, 0.707, 0.5296, 0.5268, 0.651, 0.5407, 0.618, 0.5451, 0.629, 0.5133, 0.5381, 0.909, 0.898, 0.5358, 0.5472, 0.5403, 0.5082, 0.5375, 0.784, 0.645, 0.5083, 0.590, 0.5450, 0.626, 0.657, 0.5332, 0.988, 0.550, 0.5117, 0.5201, 0.5232, 0.5056, 0.5408, 0.5028, 0.824, 0.559, 0.935, 0.943, 0.510, 0.5065, 0.575, 0.5391, 0.5474, 0.973, 0.5249, 0.5446, 0.875, 0.831, 0.5321, 0.5160, 0.976, 0.904, 0.5250, 0.926, 0.5030, 0.5407, 0.757, 0.518, 0.5457, 0.5375, 0.5219, 0.5189, 0.931, 0.5127, 0.717, 0.5255, 0.5187, 0.5152, 0.697, 0.5197, 0.716, 0.773, 0.5087, 0.690, 0.5246, 0.835, 0.636, 0.621, 0.5166, 0.5457, 0.5282, 0.642, 0.860, 0.5031, 0.5498, 0.720, 0.514, 0.5119, 0.5099, 0.586, 0.579, 0.919, 0.5312, 0.5144, 0.5130, 0.5459, 0.582, 0.5245, 0.606, 0.812, 0.5087, 0.615, 0.5293, 0.5159, 0.977, 0.543, 0.5092, 0.5053, 0.692, 0.967, 0.5207, 0.5498, 0.846, 0.5493, 0.569, 0.843, 0.713, 0.583, 0.5463, 0.5312, 0.670, 0.541, 0.731, 0.5482, 0.5186, 0.5361, 0.5441, 0.5268, 0.5106, 0.546, 0.580, 0.693, 0.662, 0.5373, 0.5352, 0.5139, 0.5417, 0.944, 0.692, 0.609, 0.5411, 0.5399, 0.606, 0.756, 0.5392, 0.676, 0.5100, 0.604, 0.759, 0.5062, 0.5417, 0.929, 0.5103, 0.647, 0.911, 0.788, 0.508, 0.851, 0.556, 0.5115, 0.898, 0.637, 0.5308, 0.5060, 0.510, 0.5160, 0.699, 0.5427, 0.603, 0.891, 0.536, 0.514, 0.790, 0.643, 0.771, 0.682, 0.819, 0.5371, 0.787, 0.5079, 0.932, 0.703, 0.508, 0.535, 0.851, 0.919, 0.824, 0.860, 0.5271, 0.881, 0.5476, 0.669, 0.5018, 0.5284, 0.5230, 0.5029, 0.943, 0.5430, 0.956, 0.5047, 0.820, 0.992, 0.5061, 0.5111, 0.5135, 0.5332, 0.5293, 0.5455, 0.5202, 0.580, 0.5033, 0.634, 0.783, 0.5041, 0.669, 0.5135, 0.5461, 0.994, 0.5496, 0.5232, 0.5375, 0.5471, 0.5401, 0.893, 0.5254, 0.5130, 0.5422, 0.696, 0.5060, 0.877, 0.5244, 0.5380, 0.5370, 0.805, 0.991, 0.5005, 0.636, 0.784, 0.959, 0.5339, 0.864, 0.5493, 0.5473, 0.5148, 0.5033, 0.642, 0.782, 0.994, 0.5137, 0.778, 0.725, 0.5011, 0.748, 0.625, 0.5405, 0.501, 0.5256, 0.5327, 0.698, 0.815, 0.704, 0.5443, 0.695, 0.573, 0.747, 0.5187, 0.5079, 0.883, 0.5471, 0.538, 0.722, 0.835, 0.530, 0.695, 0.5483, 0.5064, 0.838, 0.765, 0.557, 0.5475, 0.5043, 0.782, 0.986, 0.5292 ]
#			#}}}
			statsDataResponse.statsDataTitle = 'Example Stats'
			statsDataResponse.statsDataLabel = 'Server Load'
			statsDataResponse.statsDataFormat = '%B %e %Y' # @ %H:%M~
			statsDataResponse.statsDataType = 'daily'
			statsDataResponse.statsDataInterval = (24 * 3600 * 1000)
			statsDataResponse.statsDataStart = Date.UTC(2006, 0, 1)
			statsDataResponse.statsDataEnd = (statsDataResponse.statsDataStart + (statsDataResponse.statsDataInterval * statsDataResponse.statsData.length))
			statsDataResponse.statsDataDuration = (statsDataResponse.statsDataEnd - statsDataResponse.statsDataStart)

			# send response as JSON
			res.send JSON.stringify(statsDataResponse)
		#}}}

		#{{{ RESOURCE /stats2
		stats = module1.resource '/stats2', 'Example Chart 2'
		#}}}
		#{{{ METHOD		GET		/
		stats.method 'https', 'get', '/', portal.middleware.baseSessionAuth(), (req, res) =>
			page = portal.pengiPage 'Example Chart 2', req
			page.pengiJS.push portal.core.js('jquery.min')
			page.pengiJS.push portal.core.js('highcharts')
			page.pengiJS.push portal.core.js('highcharts-grid')
			page.pengiJS.push module1.js('stats2')
			res.render 'stats', page
		#}}}

		#{{{ RESOURCE /logs
		logs = module1.resource '/logs', 'Example MongoDB Table'
		#}}}
		#{{{ METHOD		GET		/
		logs.method 'https', 'get', '/', portal.middleware.baseSessionAuth(), (req, res) =>
			page = portal.pengiPage 'Example MongoDB Table', req
			page.pengiJS.push portal.core.js('jquery.min')
			page.pengiJS.push portal.core.js('jquery.dataTables.min')
			page.pengiJS.push module1.js('logs')
			res.render 'logs', page
		#}}}
		#{{{ METHOD		GET		/distinctip
		logs.method 'https', 'get', '/distinctip', portal.middleware.baseSessionAuthDatatable(), (req, res) =>
			@mongo.collection res, 'relaylog', (collection) =>
				collection.distinct 'ip', (err, results) =>
					try
						sresults = results.sort()
					catch e
						return res.send results
					res.send sresults
		#}}}
		#{{{ METHOD		GET		/logdata
		logs.method 'https', 'get', '/logdata', portal.middleware.baseSessionAuthDatatable(), (req, res) =>
			searchArg = if req.query.sSearch then { ip : req.query.sSearch } else {}
			skipArg = if req.query.iDisplayStart then req.query.iDisplayStart else 0
			limitArg = if req.query.iDisplayLength > 0 and req.query.iDisplayLength < 200 then req.query.iDisplayLength else 25
			sortDir = if req.query.sSortDir_0 == 'asc' then -1 else 1
			sortArg = { ts : 1 }
			if req.query.iSortCol_0
				switch req.query.iSortCol_0
					when '0'
						sortArg = { _id : sortDir }
					when '1'
						sortArg = { ip : sortDir }
					when '2'
						sortArg = { sender : sortDir }
					when '3'
						sortArg = { recipient : sortDir }
					when '4'
						sortArg = { mailsize : sortDir }

			@mongo.collection res, 'relaylog', (collection) =>
				collection.count (err, logcount) =>
					collection.find(searchArg, {}).count (err, searchcount) =>
						collection.find(searchArg, { skip : skipArg, limit : limitArg }).sort(sortArg).toArray (err, results) =>
							logData = []
							if results
								for result in results
									try
										tsraw = result._id.toString().substring(0,8)
										tsdate = new Date parseInt(tsraw, 16) * 1000
										tspretty = tsdate.toLocaleString()
									catch e
										tspretty = 'Unknown'
									logData.push
										0 : tspretty
										1 : result.ip
										2 : result.sender
										3 : result.recipient
										4 : result.mailsize
										DT_RowId : result._id
										DT_RowClass : 'nowrap'
							res.send
								sEcho : req.query.sEcho
								iTotalRecords : logcount
								iTotalDisplayRecords : searchcount
								aaData : logData
		#}}}

		#{{{ RESOURCE /hosts
		hosts = module1.resource '/hosts', 'Example MySQL Data Table'
		#}}}
		#{{{ METHOD 	GET		/
		hosts.method 'https', 'get', '/', portal.middleware.baseSessionAuth(), (req, res) =>
			page = portal.pengiPage 'Example MySQL Data Table', req
			page.pengiJS.push portal.core.js('jquery.min')
			page.pengiJS.push portal.core.js('jquery.dataTables.min')
			page.pengiJS.push portal.core.js('jquery.jeditable.mini')
			page.pengiJS.push module1.js('hosts')
			res.render 'hosts', page
		#}}}
		#{{{ METHOD		GET		/list
		hosts.method 'https', 'get', '/list', portal.middleware.baseSessionAuthDatatable(), (req, res) =>
			sortArg = 'NetworkIP'
			sortDir = if req.query.sSortDir_0 == 'asc' then 'ASC' else 'DESC'
			if req.query.iSortCol_0
				switch req.query.iSortCol_0
					when '1'
						sortArg = 'NetworkIP'
			qstr = 'SELECT id, NetworkName, INET_NTOA(NetworkIP) AS NetworkIPstr FROM MailConfig.Network ORDER BY ' + sortArg + ' ' + sortDir
			@mysql.client.query qstr, (error, results, fields) =>
				if error
					console.log 'ERROR!'
					console.log error
					return res.send error.message, 500
				networkData = []
				for result in results
					networkData.push
						0 : 'OK: under quota'
						1 : result.NetworkIPstr
						2 : result.NetworkName
						DT_RowId : result.id

				res.send
					sEcho : req.query.sEcho
					iTotalRecords : networkData.length
					iTotalDisplayRecords : networkData.length
					aaData : networkData
		#}}}
		#{{{ METHOD		POST /modify
		hosts.method 'https', 'post', '/modify', portal.middleware.baseSessionAuthDatatable(), (req, res) =>
			unless req.body and req.body.row_id and req.body.value
				return res.send 'Missing arguments', 400

			qstr = 'UPDATE MailConfig.Network SET NetworkName = ' + @mysql.client.escape(req.body.value) + ' WHERE id = ' + @mysql.client.escape(req.body.row_id)
			@mysql.client.query qstr, (error, results, fields) =>
				if error
					console.log 'ERROR!'
					console.log error
					return res.send error.message, 500

				res.send req.body.value
		#}}}

		#{{{ RESOURCE	/quotas
		quotas = module1.resource '/quotas', 'Example MySQL Data Table 2'
		#}}}
		#{{{ METHOD		GET		/
		quotas.method 'https', 'get', '/', portal.middleware.baseSessionAuth(), (req, res) ->
			page = portal.pengiPage 'Example MySQL Data Table 2', req
			page.pengiJS.push portal.core.js('jquery.min')
			page.pengiJS.push portal.core.js('jquery.dataTables.min')
			page.pengiJS.push portal.core.js('jquery.jeditable.mini')
			page.pengiJS.push module1.js('quotas')
			res.render 'quotas', page
		#}}}
		#{{{ METHOD		GET		/list
		quotas.method 'https', 'get', '/list', portal.middleware.baseSessionAuthDatatable(), (req, res) =>
			sortArg = 'QuotaName'
			sortDir = if req.query.sSortDir_0 == 'asc' then 'ASC' else 'DESC'
			if req.query.iSortCol_0
				switch req.query.iSortCol_0
					when '1'
						sortArg = 'QuotaName'
					when '2'
						sortArg = 'QuotaHourlyWarn'
					when '3'
						sortArg = 'QuotaHourlyLimit'
					when '4'
						sortArg = 'QuotaDailyWarn'
					when '5'
						sortArg = 'QuotaDailyLimit'
			qstr = 'SELECT QuotaID, QuotaName, QuotaHourlyWarn, QuotaHourlyLimit, QuotaDailyWarn, QuotaDailyLimit FROM MailConfig.Quota ORDER BY ' + sortArg + ' ' + sortDir
			@mysql.client.query qstr, (error, results, fields) =>
				if error
					console.log 'ERROR!'
					console.log error
					return res.send error.message, 500
				quotaData = []
				for result in results
					quotaData.push
						0 : result.QuotaName
						1 : result.QuotaHourlyWarn
						2 : result.QuotaHourlyLimit
						3 : result.QuotaDailyWarn
						4 : result.QuotaDailyLimit
						DT_RowId : result.QuotaID
				res.send
					sEcho : req.query.sEcho
					iTotalRecords : quotaData.length
					iTotalDisplayRecords : quotaData.length
					aaData : quotaData
		#}}}

# vim: foldmethod=marker wrap
