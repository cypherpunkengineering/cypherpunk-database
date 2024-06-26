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

class wiz.framework.util.strval

	@str_to_digits : (str) ->
		return (str.charCodeAt(c) for c of str).join('')

	# trim ipv4 in ipv6 prefix
	@inet6_prefix_trim : (ip) ->
		ipv6prefix = '::ffff:'
		if ip.indexOf ipv6prefix is 0
			ip = ip.replace ipv6prefix, ''
		return ip

	# check if on or off
	@boolean_valid: (str) ->
		return (str is 'on' or str is 'off')

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

	# same as fqdn but require at least one instance of the first half of the regex
	@fqdnDot_valid : (host) ->
		fqdnDotRegex = '(([a-zA-Z0-9]|[a-zA-Z0-9_][a-zA-Z0-9\-]*[a-zA-Z0-9])\\.)+([A-Za-z]|[A-Za-z_][A-Za-z0-9\-]*[A-Za-z0-9])'
		return (new RegExp('^' + fqdnDotRegex + '$' )).test(host)

	# same as fqdn but allow wildcards
	@fqdnWild_valid : (host) ->
		fqdnWildRegex = '(([a-zA-Z0-9*]|[a-zA-Z0-9_][a-zA-Z0-9\-]*[a-zA-Z0-9*])\\.)*([A-Za-z*]|[A-Za-z_][A-Za-z0-9\-]*[A-Za-z0-9*])'
		return (new RegExp('^' + fqdnWildRegex + '$' )).test(host)

	# check if valid string
	@str_valid : (str) ->
		strRegex = '..*'
		return (new RegExp( '^' + strRegex + '$' )).test(str)

	# check if valid string
	@email_valid : (str) ->
		strRegex = "[A-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-z0-9](?:[A-z0-9-]*[A-z0-9])?\.)+[A-z0-9](?:[A-z0-9-]*[A-z0-9])?"
		return (new RegExp( '^' + strRegex + '$' )).test(str)

	# check if valid string
	@btcaddr_base58_mainnet_valid : (str) ->
		strRegex = '[13][a-km-zA-HJ-NP-Z0-9]{26,33}'
		return (new RegExp( '^' + strRegex + '$' )).test(str)

	# check if valid string
	@base64imgblob_valid : (str) ->
		strRegex = 'data:image\/[a-z]*;base64,(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?'
		return (new RegExp( '^' + strRegex + '$' )).test(str)

	# check if valid integer
	@int_valid : (i) ->
		return parseFloat(i) == parseInt(i) && (!isNaN(i) && i % 1 == 0)

	# check if valid integer
	@ttl_valid : (ttl) ->
		return false unless @int_valid(ttl)
		return (ttl >= 60 and ttl <= (60 * 60 * 24 * 7))

	# check if valid string
	@url_valid : (str) ->
		strRegex = '(http|https):\/\/[^ "]+'
		return (new RegExp( '^' + strRegex + '$' )).test(str)

	# check if valid 8 digit hotp code
	@hotp_valid : (str) -> /^\d{8}$/.test(str)

	# check if valid 8 digit wizkey id
	@wizkey_valid : (str) -> /^\d{8}$/.test(str)

	# check if valid 20 digit leetcode
	@leetcode_valid : (str) -> /^1337\d{8}\d{8}$/.test(str)

	# check if valid ascii
	@ascii_valid : (str) ->
		for c, i in str
			code = str.charCodeAt(i)
			if code < 32 or code > 127
				return false
		return true

	# check if valid alphanumeric
	@alphanumeric_valid : (str) -> /^[A-Za-z0-9]*$/.test(str)

	# check if valid alphanumericdot
	@alphanumericdot_valid : (str) -> /^[A-Za-z0-9\.]*$/.test(str)

	# compare two strings insensitively
	@strncmp : (str1, str2, n) ->
		str1 = str1.substring 0, n
		str2 = str2.substring 0, n
		return ( str1 == str2 ) ? 0 : (( str1 > str2 ) ? 1 : -1 )

	@validate: (argtype, value) =>
		if typeof value != 'string'
			console.log 'non-string type passed to string validation method'
			return false
		switch argtype
			when 'alphanumeric'
				return @alphanumeric_valid(value)
			when 'alphanumericdot'
				return @alphanumericdot_valid(value)
			when 'ascii'
				return @ascii_valid(value)
			when 'asciiNoQuote'
				return (@ascii_valid(value) && value.indexOf('"') == -1 && value.indexOf("'") == -1)
			when 'asciiNoSpace'
				return (@ascii_valid(value) && value.indexOf(' ') == -1)
			when 'base64imgblob'
				return @base64imgblob_valid(value)
			when 'boolean'
				return @boolean_valid(value)
			when 'fqdn'
				return @fqdn_valid(value)
			when 'fqdnOrAt'
				return (@fqdn_valid(value) || value == '@')
			when 'fqdnWildOrAt'
				return (@fqdnWild_valid(value) || value == '@')
			when 'fqdnDot'
				return @fqdnDot_valid(value)
			when 'fqdnDotOrDot'
				return (@fqdnDot_valid(value) || value == '.')
			when 'inet4'
				return @inet4_valid(value)
			when 'inet6'
				return @inet6_valid(value)
			when 'int'
				return @int_valid(value)
			when 'int8b'
				return @int_valid(value) && value >= 0 && value <= 255
			when 'email'
				return @email_valid(value)
			when 'pulldown'
				return true # XXX hack
			when 'btcaddrB58mainnet'
				return @btcaddr_base58_mainnet_valid(value)
			when 'str'
				return @str_valid(value)
			when 'ttl'
				return @ttl_valid(value)
			when 'url'
				return @url_valid(value)
			else # unknown
				console.log 'unknown string validation type '+argtype
				return false

# vim: foldmethod=marker wrap
