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

# wizutil package
wizpackage 'wizutil'

class wizutil.wizstring

	# trim ipv4 in ipv6 prefix
	@inet6_prefix_trim : (ip) ->
		ipv6prefix = '::ffff:'
		if ip.indexOf ipv6prefix is 0
			ip = ip.replace ipv6prefix, ''
		return ip

	# check if valid ipv4 address
	@inet4_valid : (ip) ->
		octet = '(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])'
		ipRegex = '(?:' + octet + '\\.){3}' + octet
		return (new RegExp( '^' + ipRegex + '$' )).test(ip)

	# convert 32 bit integer to dotted quad ipv4 address
	@inet4_ntoa : (int) ->
		part1 = int & 255
		part2 = ((int >> 8) & 255)
		part3 = ((int >> 16) & 255)
		part4 = ((int >> 24) & 255)
		return part4 + "." + part3 + "." + part2 + "." + part1

	# convert dotted quad ipv4 address to 32 bit integer
	@inet4_aton : (ip) ->
		return 0 unless @inet4_valid(ip)
		d = ip.split('.')
		return ((((((+d[0])*256)+(+d[1]))*256)+(+d[2]))*256)+(+d[3])

	# compare two strings insensitively
	@strncmp : (str1, str2, n) ->
		str1 = str1.substring 0, n
		str2 = str2.substring 0, n
		return ( str1 == str2 ) ? 0 : (( str1 > str2 ) ? 1 : -1 )

# vim: foldmethod=marker wrap
