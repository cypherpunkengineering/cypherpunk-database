# Based on speakeasy @ https://github.com/markbao/speakeasy
# HOTP (HMAC-Based One-Time Password Algorithm): [RFC 4226](http:#tools.ietf.org/html/rfc4226)
# TOTP (Time-Based One-Time Password Algorithm): [RFC 6238](http:#tools.ietf.org/html/rfc6238)

require('..')

wizpackage('wiz.framework.util.otp')

crypto = require('crypto')
ezcrypto = require('ezcrypto').Crypto
base32 = require('thirty-two')

class wiz.framework.util.otp

	# wiz.framework.util.otp.hotp(options)
	#
	# Calculates the one-time password given the key and a counter.
	#
	# options.key                  the key
	#        .counter              moving factor
	#        .length(=6)           length of the one-time password (default 6)
	#        .encoding(='ascii')   key encoding (ascii, hex, or base32)
	#
	@hotp: (options) =>
		# set vars
		key = options.key
		counter = options.counter
		length = options.length || 6
		encoding = options.encoding || 'base32'

		# preprocessing: convert to ascii if it's not
		if (encoding == 'hex')
			key = wiz.framework.util.otp.hex_to_ascii(key)
		else if (encoding == 'base32')
			key = base32.decode(key)

		# init hmac with the key
		hmac = crypto.createHmac('sha1', new Buffer(key))

		# create an octet array from the counter
		octet_array = new Array(8)

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
		digest_bytes = ezcrypto.util.hexToBytes(digest)

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

		# we now have a code with `length` number of digits, so return it
		return(code)

	# wiz.framework.util.otp.totp(options)
	#
	# Calculates the one-time password given the key, based on the current time
	# with a 30 second step (step being the number of seconds between passwords).
	#
	# options.key                  the key
	#        .length(=6)           length of the one-time password (default 6)
	#        .encoding(='ascii')   key encoding (ascii, hex, or base32)
	#        .step(=30)            override the step in seconds
	#        .time                 (optional) override the time to calculate with
	#        .initial_time         (optional) override the initial time
	#
	@totp: (options) =>
		# set vars
		key = options.key
		length = options.length || 6
		encoding = options.encoding || 'base32'
		step = options.step || 30
		initial_time = options.initial_time || 0; # unix epoch by default

		# get current time in seconds since unix epoch
		time = parseInt(Date.now()/1000)

		# are we forcing a specific time?
		if (options.time)
			# override the time
			time = options.time

		# calculate counter value
		counter = Math.floor((time - initial_time)/ step)

		# pass to hotp
		code = this.hotp({key: key, length: length, encoding: encoding, counter: counter})

		# return the code
		return(code)

	# wiz.framework.util.otp.hex_to_ascii(key)
	#
	# helper function to convert a hex key to ascii.
	#
	@hex_to_ascii: (str) =>
		# key is a string of hex
		# convert it to an array of bytes...
		bytes = ezcrypto.util.hexToBytes(str)

		# bytes is now an array of bytes with character codes
		# merge this down into a string
		ascii_string = new String()

		for i of bytes
			ascii_string += String.fromCharCode(bytes[i])

		return ascii_string

	# wiz.framework.util.otp.ascii_to_hex(key)
	#
	# helper function to convert an ascii key to hex.
	#
	@ascii_to_hex: (str) =>
		hex_string = ''

		for i of str
			hex_string += str.charCodeAt(i).toString(16)

		return hex_string

	# wiz.framework.util.otp.generate_key(options)
	#
	# Generates a random key with the set A-Z a-z 0-9 and symbols, of any length
	# (default 32). Returns the key in ASCII, hexadecimal, and base32 format.
	# Base32 format is used in Google Authenticator. Turn off symbols by setting
	# symbols: false. Automatically generate links to QR codes of each encoding
	# (using the Google Charts API) by setting qr_codes: true. Automatically
	# generate a link to a special QR code for use with the Google Authenticator
	# app, for which you can also specify a name.
	#
	# options.length(=32)              length of key
	#        .symbols(=true)           include symbols in the key
	#        .qr_codes(=false)         generate links to QR codes
	#        .google_auth_qr(=false)   generate a link to a QR code to scan
	#                                  with the Google Authenticator app.
	#        .name                     (optional) add a name. no spaces.
	#                                  for use with Google Authenticator
	#
	@generate_key: (options) =>
		# options
		length = options.length || 32
		name = options.name || "Secret Key"
		qr_codes = options.qr_codes || false
		google_auth_qr = options.google_auth_qr || true
		symbols = true

		# turn off symbols only when explicity told to
		if (options.symbols isnt undefined && options.symbols is false)
			symbols = false

		# generate an ascii key
		key = this.generate_key_ascii(length, symbols)

		# return a SecretKey with ascii, hex, and base32
		SecretKey = {}
		SecretKey.ascii = key
		SecretKey.hex = this.ascii_to_hex(key)
		SecretKey.base32 = base32.encode(key).replace /\=/g,''

		baseURL = 'https:#chart.googleapis.com/chart?chs=166x166&chld=L|0&cht=qr&chl='

		# generate a QR code for use in Google Authenticator if requested
		# (Google Authenticator has a special style and requires base32)
		if (google_auth_qr)
			# first, make sure that the name doesn't have spaces, since Google Authenticator doesn't like them
			name = name.replace /\ /g,''
			SecretKey.google_auth_qr = baseURL + 'otpauth:#totp/' + encodeURIComponent(name) + '%3Fsecret=' + encodeURIComponent(SecretKey.base32)

		return SecretKey

	# wiz.framework.util.otp.generate_key_ascii(length, symbols)
	#
	# Generates a random key, of length `length` (default 32).
	# Also choose whether you want symbols, default false.
	# wiz.framework.util.otp.generate_key() wraps around this.
	#
	@generate_key_ascii: (length, symbols) =>
		length = 32 if (!length)

		set = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz'

		if (symbols)
			set += '!@#$%^&*()<>?/[]{},.:;'

		key = ''

		for i in [0..length]
			key += set.charAt(Math.floor(Math.random() * set.length))

		return key

# vim: foldmethod=marker wrap
