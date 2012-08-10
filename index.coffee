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

global.wizlog = require './wizlog'

global.rootpath = process.cwd()

global.wizapp = (appname) ->
	global.appname = appname
	global.wizlog.init()

global.wizpackage = (name) ->
	levels = name.split '.'
	space = global
	for ns, i in levels
		# console.log levels[0..i].join('.')
		space[ns] = space[ns] or {}
		space = space[ns]

process.on 'SIGINT', =>
	process.exit()

global.wizassert = (expr, tag, err) ->
	return if expr
	wizlog.err tag, "ASSERTION FAIL! #{err}"

# vim: foldmethod=marker wrap
