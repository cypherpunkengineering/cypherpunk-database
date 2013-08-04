# wiz framework crypto one-time password classes
# copyright 2012-2013 wiz technologies inc.
#
# some portions based on excerpts from:
# "speakeasy - HMAC One-Time Password module for Node.js"
# copyright 2012-2013 Mark Bao
# https://github.com/markbao/speakeasy
# licensed pursuant to terms of the MIT license:
# https://github.com/markbao/speakeasy/blob/master/LICENSE
#
# some portions based on excerpts from:
# "otptool - HOTP/OATH one-time password utility"
# copyright 2009 Archie L. Cobbs <archie@dellroad.org>
# https://code.google.com/p/mod-authn-otp/
# licensed pursuant to terms of the apache license 2.0:
# https://www.apache.org/licenses/LICENSE-2.0
#
# this implementation supports the following algorithms:
#
# TOTP (Time-Based One-Time Password Algorithm), as defined by RFC 6238:
# http://tools.ietf.org/html/rfc6238
#
# HOTP (HMAC-Based One-Time Password Algorithm), as defined by RFC 4226:
# http://tools.ietf.org/html/rfc4226

require '..'
require '../util/datetime'
require '../util/convert'

wiz.package 'wiz.framework.util.otp'

crypto = require 'crypto'
BigInteger = require '../crypto/jsbn'

class wiz.framework.util.otp

	@hotp: (keybuf, counter, length = 8) -> # generates a one-time password of given length from given key and counter {{{
		# init hmac with the key
		hmac = crypto.createHmac('sha1', keybuf)

		# create an octet array from the counter
		octet_array = new Array(8)

		# encode the counter to be signed
		counter_temp = counter

		for i in [0..8]
			i_from_right = 7 - i

			# mask 255 over number to get last 8
			octet_array[i_from_right] = counter_temp & 255

			# shift 8 and get ready to loop over the next batch of 8
			counter_temp = counter_temp >> 8

		# create a buffer from the octet array
		counter_buffer = new Buffer(octet_array)

		# update hmac with the counter
		hmac.update(counter_buffer)

		# get the digest in hex format
		digest = hmac.digest('hex')

		# convert the result to an array of bytes
		digest_bytes = []
		for c in [0...digest.length] by 2
			digest_bytes.push(parseInt(digest.substr(c, 2), 16))

		# compute HOTP
		# get offset
		offset = digest_bytes[19] & 0xf

		# calculate bin_code (RFC4226 5.4)
		bin_code = (digest_bytes[offset] & 0x7f) << 24
		bin_code |= (digest_bytes[offset+1] & 0xff) << 16
		bin_code |= (digest_bytes[offset+2] & 0xff) << 8
		bin_code |= (digest_bytes[offset+3] & 0xff)

		bin_code = bin_code.toString()

		# get the chars at position bin_code - length through length chars
		sub_start = bin_code.length - length
		code = bin_code.substr(sub_start, length)

		# we now have a code with `length` number of digits, so return it in convenient ways
		return code
	#}}}
	@totp: (keybuf, step = 30, length = 6, time = 0, initial_time = 0) -> # generates a one-time password of given length from given key and timestamp {{{
		# use current time if not given
		time = time || wiz.framework.util.datetime.unixTS()

		# calculate counter value
		counter = Math.floor((time - initial_time) / step)

		# pass to hotp
		return @hotp(keybuf, counter, length)
	#}}}

	@generateSecret: (length = 20) => # generates a secret of given length for above OTP methods #{{{
		loop # loop until full length random number is returned
			secret = new BigInteger(crypto.randomBytes(length)).abs()
			break if secret.toString(16).length is length*2
		out =
			dec: secret.toString(10)
			hex: secret.toString(16).toUpperCase()
			base32: wiz.framework.util.convert.biToBase32(secret)

		return out
	#}}}

# vim: foldmethod=marker wrap
