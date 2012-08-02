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

# wiz-framework
require '..'
require '../wizdb'
require '../wizutil/wizstring'

# wizfrontend package
wizpackage 'wizfrontend'

class wizfrontend.tablemanager

	constructor: (@parent) ->
		wizassert(false, "invalid @parent: #{@parent}") if not @parent

	validateInputType: (inputType, inputValue) =>
		return wizutil.wizstring.validate(inputType, inputValue)

	insert: (req, res) =>
	modify: (req, res) =>
	drop: (req, res) =>

# vim: foldmethod=marker wrap
