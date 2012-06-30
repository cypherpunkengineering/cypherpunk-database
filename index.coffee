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
global.pkgname = 'wiz-framework'

global.wizpackage = (name) ->
	global[name] = global[name] or {}
	global.pkgname = name

process.on 'SIGINT', =>
	process.exit()

# vim: foldmethod=marker wrap
