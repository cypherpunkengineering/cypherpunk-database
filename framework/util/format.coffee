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

class wiz.framework.util.format
	@centsAsUSD: (amount) => #{{{
		dollars = Math.floor(Math.abs(amount / 100))
		cents = ('00' + Math.abs(amount) % 100).slice(-2)
		usd = dollars + '.' + cents
		out = usd
		return out
	#}}}

# vim: foldmethod=marker wrap
