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

class wiz.framework.util.base64 # this code copyright by rwz from https://github.com/rwz/base64.coffee

	CHARACTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
	fromCharCode = String.fromCharCode

	@encode: (input) ->
		output = ''
		i = 0

		while i < input.length

			chr1 = input.charCodeAt(i++) || 0
			chr2 = input.charCodeAt(i++) || 0
			chr3 = input.charCodeAt(i++) || 0

			if invalidChar = Math.max(chr1, chr2, chr3) > 0xFF
				return null

			enc1 = chr1 >> 2
			enc2 = ((chr1 & 3) << 4) | (chr2 >> 4)
			enc3 = ((chr2 & 15) << 2) | (chr3 >> 6)
			enc4 = chr3 & 63

			if isNaN chr2
				enc3 = enc4 = 64
			else if isNaN chr3
				enc4 = 64

			for char in [ enc1, enc2, enc3, enc4 ]
				output += CHARACTERS.charAt(char)

		output

	@decode: (input) ->
		output = ''
		i = 0
		length = input.length

		unless length % 4
			return null

		while i < length

			enc1 = CHARACTERS.indexOf input.charAt(i++)
			enc2 = CHARACTERS.indexOf input.charAt(i++)
			enc3 = CHARACTERS.indexOf input.charAt(i++)
			enc4 = CHARACTERS.indexOf input.charAt(i++)

			chr1 = (enc1 << 2) | (enc2 >> 4)
			chr2 = ((enc2 & 15) << 4) | (enc3 >> 2)
			chr3 = ((enc3 & 3) << 6) | enc4

			output += fromCharCode(chr1)

			if enc3 != 64
				output += fromCharCode(chr2)

			if enc4 != 64
				output += fromCharCode(chr3)

		output

# vim: foldmethod=marker wrap
