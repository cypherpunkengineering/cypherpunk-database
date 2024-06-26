# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../client/query'

crypto = require 'crypto'

wiz.package 'wiz.framework.http.oauth'

class wiz.framework.http.oauth.consumer extends wiz.framework.http.client.query

	constructor: (options = {}) -> #{{{

		wiz.assert (@consumerKey = options.consumerKey), 'OAuth consumer key'
		wiz.assert (@consumerSecret = options.consumerSecret), 'OAuth consumer secret'

		@ssl = if options.ssl is false then false else true
		wiz.assert (@host = options.host), 'OAuth host'
		wiz.assert (@port = options.port || 443), 'OAuth port'

		wiz.assert (@hashMethod = options.hashMethod || 'HMAC-SHA1'), 'OAuth hash method'

	#}}}
	reqOptions: (method, path, callbackURL, oauthToken, oauthTokenSecret, params, body) => # generate request options #{{{

		# Example OAuth query to tweet on twitter:
		#
		# POST /1/statuses/update.json?include_entities=true HTTP/1.1
		# Connection: close
		# User-Agent: OAuth gem v0.4.4
		# Content-Type: application/x-www-form-urlencoded
		# Authorization:
		#         OAuth oauth_consumer_key="xvz1evFS4wEEPTGEFPHBog",
		#               oauth_nonce="kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg",
		#               oauth_signature="tnnArxj06cWHq44gCs1OSKk%2FjLY%3D",
		#               oauth_signature_method="HMAC-SHA1",
		#               oauth_timestamp="1318622958",
		#               oauth_token="370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb",
		#               oauth_version="1.0"
		# Content-Length: 76
		# Host: api.twitter.com
		#
		# status=Hello%20Ladies%20%2b%20Gentlemen%2c%20a%20signed%20OAuth%20request%21

		# get base opts
		opts = super(method, path, params, body)

		opts.headers['Accept'] = 'application/json, text/html'
		opts.headers['Content-Type'] = 'application/x-www-form-urlencoded' if method is 'POST'
		# generate Authorization header from request params
		opts.headers['Authorization'] = @authorization(ts, method, path, params, callbackURL, oauthToken, oauthTokenSecret)

		console.log opts
		return opts
	#}}}
	authorization: (ts, method, path, headers = {}, callbackURL = null, oauthToken = null, oauthTokenSecret = null) => #{{{

		#headers['include_entities'] = true

		# generate oauth_* headers
		headers['oauth_callback'] = callbackURL if callbackURL
		headers['oauth_consumer_key'] = @consumerKey
		headers['oauth_nonce'] = wiz.framework.util.datetime.unixFullTS(ts)
		headers['oauth_signature_method'] = @hashMethod
		headers['oauth_timestamp'] = wiz.framework.util.datetime.unixTS(ts)
		headers['oauth_token'] = oauthToken if oauthToken
		headers['oauth_version'] = '1.0'

		# generate signature from the combined request params + oauth_* headers
		headers['oauth_signature'] = @signature(method, path, headers, oauthTokenSecret)

		# sort headers, encode keys and values, concat into paramString
		params = []
		params.push @encode(key) + '="' + @encode(headers[key]) + '"' for key of headers
		authString = 'OAuth ' + params.sort().join(',')

		wiz.log.debug "authorization: #{authString}"

		return authString
	#}}}
	signature: (method, path, headers, oauthTokenSecret) => #{{{

		# sort headers, encode keys and values, concat into paramString
		params = []
		params.push @encode(key) + '=' + @encode(headers[key]) for key of headers
		paramString = params.sort().join('&')

		# wiz.log.debug 'paramString should look like this: include_entities=true&oauth_consumer_key=xvz1evFS4wEEPTGEFPHBog&oauth_nonce=kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1318622958&oauth_token=370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb&oauth_version=1.0&status=Hello%20Ladies%20%2B%20Gentlemen%2C%20a%20signed%20OAuth%20request%21'
		wiz.log.debug "paramString: #{paramString}"

		# cat method, url, and above paramString
		signatureBaseString = [
			method.toUpperCase()
			@encode(@proto() + '://' + @host + path)
			@encode(paramString)
		].join('&')

		# wiz.log.debug 'signatureBaseString should look like this: POST&https%3A%2F%2Fapi.twitter.com%2F1%2Fstatuses%2Fupdate.json&include_entities%3Dtrue%26oauth_consumer_key%3Dxvz1evFS4wEEPTGEFPHBog%26oauth_nonce%3DkYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1318622958%26oauth_token%3D370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb%26oauth_version%3D1.0%26status%3DHello%2520Ladies%2520%252B%2520Gentlemen%252C%2520a%2520signed%2520OAuth%2520request%2521'
		wiz.log.debug "signatureBaseString: #{signatureBaseString}"

		# the lion keys combine to form voltron
		signingKey = @consumerSecret
		if oauthTokenSecret
			signingKey += oauthTokenSecret
		else
			signingKey += '&'

		# hash it up
		oauthSignature = crypto.createHmac('sha1', signingKey).update(signatureBaseString).digest('base64')
		wiz.log.debug "signature: #{oauthSignature}"

		return oauthSignature
	#}}}
	encode: (str) => #{{{
		dontNeedEncoding =  [ #{{{
			# https://dev.twitter.com/docs/auth/percent-encoding-parameters
			# digits: 0-9
			0x30, 0x31, 0x32, 0x33, 0x34, 0x35,
			0x36, 0x37, 0x38, 0x39
			# uppercase letters: A-Z
			0x41, 0x42, 0x43, 0x44, 0x45, 0x46,
			0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C,
			0x4D, 0x4E, 0x4F, 0x50, 0x51, 0x52,
			0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
			0x59, 0x5A
			# lowercase letters: a-z
			0x61, 0x62, 0x63, 0x64, 0x65, 0x66,
			0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C,
			0x6D, 0x6E, 0x6F, 0x70, 0x71, 0x72,
			0x73, 0x74, 0x75, 0x76, 0x77, 0x78,
			0x79, 0x7A
			# reserved chars: '-', '.', '_', '~'
			0x2D, 0x2E, 0x5F, 0x7E
		] #}}}

		return str if typeof str is 'number'

		out = ''

		# check each char in string if it needs to be encoded
		for char in str

			if typeof char is 'number'
				charCode = char
			else
				charCode = char.charCodeAt(0)

			# if it's safe, just copy it and continue
			if dontNeedEncoding.indexOf(charCode) != -1
				out += char

			else # otherwise, percent-encode it like so:
				out += charCode.toString(16).toUpperCase().replace(/(.{2})/g, '%$1')

		return out
	#}}}

class wiz.framework.http.oauth.twitter extends wiz.framework.http.oauth.consumer

	constructor: (options = {}) -> #{{{
		options.host ?= 'api.twitter.com'
		options.port ?= 443
		options.ssl ?= true
		super(options)
	#}}}
	requestToken: (callbackURL, cb) => #{{{
		# POST /oauth/request_token HTTP/1.1
		# User-Agent: themattharris' HTTP Client
		# Host: api.twitter.com
		# Authorization:
		#         OAuth oauth_callback="http%3A%2F%2Flocalhost%2Fsign-in-with-twitter%2F",
		#               oauth_consumer_key="cChZNFj6T5R0TigYB9yd1w",
		#               oauth_nonce="ea9ec8429b68d6b77cd5600adbbb0456",
		#               oauth_signature="F1Li3tvehgcraF8DMJ7OyxO4w9Y%3D",
		#               oauth_signature_method="HMAC-SHA1",
		#               oauth_timestamp="1318467427",
		#               oauth_version="1.0"

		req = @reqCreate @reqOptions('POST', '/oauth/request_token', callbackURL), true, (res) =>
			if not res or not res.oauth_token or not res.oauth_token_secret
				return cb 'FAIL'
			cb null, res.oauth_token, res.oauth_token_secret, res.oauth_callback_confirmed

		@reqSend(req)
	#}}}
	req: (method, path, oauthAccessToken, oauthAccessTokenSecret, cb) => #{{{
		req = @reqCreate @reqOptions(method, path, null, oauthAccessToken, oauthAccessTokenSecret), true, (res) =>
			if not res
				return cb 'FAIL'
			cb null, res

		@reqSend(req)
	#}}}

# vim: foldmethod=marker wrap
