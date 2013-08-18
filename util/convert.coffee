# wiz framework base conversion utility methods
# copyright 2013 wiz technologies inc.

require '..'

wiz.package 'wiz.framework.util.convert'

BigInteger = require '../crypto/jsbn'

class wiz.framework.util.convert
	# old @base32charset: '123456789ABCDEFGHJKLMNPRSTUVWXYZ'
	# alt @base32charset: '0123456789abcdefghjkmnpqrtuvwxyz'
	@base32charset: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'

	@hex2ascii: (str) => # convert a hex byte string to ascii string of hex bytes {{{
		# first convert to an array of bytes
		bytes = []
		for c in [0...str.length] by 2
			bytes.push(parseInt(str.substr(c, 2), 16))

		# bytes is now an array of bytes with character codes
		# merge this down into a string
		ascii_string = new String()

		for i of bytes
			ascii_string += String.fromCharCode(bytes[i])

		return ascii_string
	#}}}
	@ascii2hex: (str) => # convert an ascii string of hex bytes to a hex byte string {{{
		hex_string = ''

		for i of str
			hex_string += str.charCodeAt(i).toString(16)

		return hex_string
	#}}}

	@biToBase32: (n, charset = @base32charset, length = -1) => # print BigInteger as base32 {{{
		n = n.abs() # negative numbers aren't supported for now
		base = new BigInteger('32')
		out = ''
		loop
			d = n.divideAndRemainder(base)
			n = d[0]
			r = d[1]
			out = charset.charAt(r) + out
			if n.compareTo(base) < 0
				out = charset.charAt(n) + out
				break
		if length > 0
			out = @padFront(out, length, charset[0])
		return out
	#}}}

	@num2base: (number, base, symbols, position = 0, result = '') => # converts a number to given base {{{
		if number < Math.pow(base, position + 1)
			return symbols[(number / Math.pow(base, position))] + result

		remainder = (number % Math.pow(base, position + 1))
		return @num2base(number - remainder, base, symbols, position + 1, symbols[remainder / ( Math.pow(base, position) )] + result)
	#}}}
	@num2base32: (number, length) => # converts a number into wizBase32 and pads back to given length with equals sign {{{
		b32 = @num2base(number, 32, @base32charset)
		b32padded = @padBack(number, length, '=')
		return b32padded
	#}}}
	@num2wiz32: (number, length) => # converts a number to wizBase32 and pads front to given length with 0 {{{
		wiz32 = @num2base(number, 32, @base32charset)
		wiz32padded = @padFront(wiz32, length, @base32charset[0])
		return wiz32padded
	#}}}

	@padFront: (number, length, padchar) => #{{{ pads front of number with given symbol to given length
		number = padchar + number while number.length < length
		return number
	#}}}
	@padBack: (number, length, padchar) => #{{{ pads back of number with given symbol to given length
		number = number + padchar while number.length < length
		return number
	#}}}

# vim: foldmethod=marker wrap
