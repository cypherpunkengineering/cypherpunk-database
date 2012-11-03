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
require './strval'

wiz.package 'wiz.framework.util'

class wiz.framework.util.cidr
	constructor: (@netnum, @masklen) ->
		@netdec = wiz.framework.util.strval.inet4_aton @netnum
		@netbin = @netdec.toString 2
		@maskbin = ('1' for i in [1..@masklen]).join('') + ('0' for i in [(@masklen+1)..32]).join('')
		@maskdec = parseInt(@maskbin, 2)
		@masknum = wiz.framework.util.strval.inet4_ntoa @maskdec
		#console.log "#{@netnum}/#{@masklen} = #{@netdec} #{@maskbin} #{@masknum}"

	test: (ip) =>
		ipdec = wiz.framework.util.strval.inet4_aton ip
		#ipbin = ipdec.toString 2
		return (@netdec & @maskdec) == (ipdec & @maskdec)

# vim: foldmethod=marker wrap
