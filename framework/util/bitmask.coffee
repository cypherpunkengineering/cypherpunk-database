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

require '..'

wiz.package 'wiz.framework.util'

class wiz.framework.util.bitmask
	@check: (n, mask) ->
    	return (n >> mask) % 2 != 0

	@set: (n, mask) ->
    	return n | (1 << mask)

	@clear: (n, mask) ->
    	return n & ~(1 << mask)

	@toggle: (n, mask) ->
		return n ^ (1 << mask)

# vim: foldmethod=marker wrap
