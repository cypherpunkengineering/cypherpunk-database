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

wizpackage 'wiz.util'

class wiz.util.strval

	@str_to_digits : (str) ->
		return (str.charCodeAt(c) for c of str).join('')

	# trim ipv4 in ipv6 prefix
	@inet6_prefix_trim : (ip) ->
		ipv6prefix = '::ffff:'
		if ip.indexOf ipv6prefix is 0
			ip = ip.replace ipv6prefix, ''
		return ip

	# check if valid ipv4 address
	@inet4_valid : (ip) ->
		ipv4octet = '(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])'
		ipv4Regex = '(?:' + ipv4octet + '\\.){3}' + ipv4octet
		return (new RegExp( '^' + ipv4Regex + '$' )).test(ip)

	# check if valid ipv6 address
	@inet6_valid : (ip) ->
		ipv6Regex = '(\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*)'
		return (new RegExp( '^' + ipv6Regex + '$' )).test(ip)

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

	# check if valid fqdn
	@fqdn_valid : (host) ->
		fqdnRegex = '(([a-zA-Z0-9]|[a-zA-Z0-9_][a-zA-Z0-9\-]*[a-zA-Z0-9])\\.)*([A-Za-z]|[A-Za-z_][A-Za-z0-9\-]*[A-Za-z0-9])'
		return (new RegExp('^' + fqdnRegex + '$' )).test(host)

	# same as above fqdn but make require first half of regex
	@fqdnDot_valid : (host) ->
		fqdnDotRegex = '(([a-zA-Z0-9]|[a-zA-Z0-9_][a-zA-Z0-9\-]*[a-zA-Z0-9])\\.)+([A-Za-z]|[A-Za-z_][A-Za-z0-9\-]*[A-Za-z0-9])'
		return (new RegExp('^' + fqdnDotRegex + '$' )).test(host)

	# check if valid string
	@str_valid : (str) ->
		strRegex = '..*'
		return (new RegExp( '^' + strRegex + '$' )).test(str)

	# check if valid integer
	@int_valid : (i) ->
		return parseFloat(i) == parseInt(i) && (!isNaN(i) && i % 1 == 0)

	# check if valid integer
	@ttl_valid : (ttl) ->
		return false unless @int_valid(ttl)
		return (ttl >= 60 and ttl <= (60 * 60 * 24 * 7))

	# check if valid ascii
	@ascii_valid : (str) ->
		for c, i in str
			code = str.charCodeAt(i)
			if code < 32 or code > 127
				return false
		return true

	# compare two strings insensitively
	@strncmp : (str1, str2, n) ->
		str1 = str1.substring 0, n
		str2 = str2.substring 0, n
		return ( str1 == str2 ) ? 0 : (( str1 > str2 ) ? 1 : -1 )

	@validate: (argtype, value) =>
		return false unless typeof value == 'string'
		switch argtype
			when 'ascii'
				return @ascii_valid(value)
			when 'asciiNoQuote'
				return (@ascii_valid(value) && value.indexOf('"') == -1 && value.indexOf("'") == -1)
			when 'fqdnOrAt'
				return (@fqdn_valid(value) || value == '@')
			when 'fqdnDot'
				return @fqdnDot_valid(value)
			when 'fqdnDotOrDot'
				return (@fqdnDot_valid(value) || value == '.')
			when 'fqdn'
				return @fqdn_valid(value)
			when 'inet4'
				return @inet4_valid(value)
			when 'inet6'
				return @inet6_valid(value)
			when 'int'
				return @int_valid(value)
			when 'int8b'
				return @int_valid(value) && value >= 0 && value <= 255
			when 'str'
				return @str_valid(value)
			when 'ttl'
				return @ttl_valid(value)
			else # unknown
				return false

# vim: foldmethod=marker wrap
