require '..'
require '../http/client/base'

crypto = require 'crypto'
util = require 'util'

wiz.package 'wiz.framework.thirdparty.amazon'

class wiz.framework.thirdparty.amazon
	class httpreq extends wiz.framework.http.client.base

	debug: true

	constructor: (args = {}) -> #{{{
		@AWSAccessKeyId = args.AWSAccessKeyId # AKIAJKYFSJU7PEXAMPLE
		@SellerId = args.SellerId
		@ClientSecret = args.ClientSecret
		if wiz.style is 'DEV'
			@ApiPath = "/OffAmazonPayments_Sandbox/2013-01-01"
		else
			@ApiPath = "/OffAmazonPayments/2013-01-01"
	#}}}
	baseRequestOptions: #{{{
		host: 'mws.amazonservices.com'
	#}}}

	createStringToSign: (nameValues) => #{{{
		# takes nameValues and converts it to something like this
		# AWSAccessKeyId=&Action=SetBillingAgreementDetails&AmazonBillingAgreementId=&SellerId=&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2017-01-19T05%3A15%3A03Z&Version=2013-01-01"
		keys = []
		for k of nameValues
			keys.push k
		str = ''
		keys = keys.sort()
		i = 0
		while i < keys.length
			if i != 0
				str += '&'
			str += keys[i] + '=' + nameValues[keys[i]]
			i++
		return str
	#}}}

	setBillingAgreementDetails: (req, res, args, cb) => #{{{
		endpoint = @baseRequestOptions.host
		apiPath = @ApiPath
		timestamp = new Date().toISOString()

		amazonHeaders =
			AWSAccessKeyId: @AWSAccessKeyId
			Action: "SetBillingAgreementDetails"
			SellerId: @SellerId
			#MWSAuthToken: "amzn.mws.4ea38b7b-f563-7709-4bae-87aeaEXAMPLE"
			SignatureMethod: "HmacSHA256"
			SignatureVersion: "2"
			Timestamp: encodeURIComponent(timestamp) # 2013-12-11T10%3A57%3A18.000Z
			Version: "2013-01-01"

		amazonBody =
			AmazonBillingAgreementId: args.AmazonBillingAgreementId # C01-8824045-7416542
			"BillingAgreementAttributes.SellerNote": args.AmazonBillingAgreementId # C01-8824045-7416542
			"BillingAgreementAttributes.SellerBillingAgreementAttributes.CustomInformation": args.email

		combinedObject = {}
		Object.assign(combinedObject, amazonHeaders)
		Object.assign(combinedObject, amazonBody)

		stringToSign = "POST\n"
		stringToSign += endpoint + "\n"
		stringToSign += apiPath + "\n"
		stringToSign += @createStringToSign(combinedObject)

		hmac = crypto.createHmac('sha256', @ClientSecret)
		hmac.update(stringToSign)
		signature = hmac.digest('base64') # Z0ZVgWu0ICF4FLxt1mTjyK%2BjdYG6Kmm8JxLTfsQtKRY%3D

		console.log "stringToSign is"
		console.log stringToSign

		console.log "signature is"
		console.log signature

		reqBody = ""
		for key of amazonHeaders
			reqBody += key + "=" + amazonHeaders[key] + "&"
		for key of amazonBody
			reqBody += key + "=" + amazonBody[key] + "&"
		reqBody += 'Signature=' + encodeURIComponent(signature)

		console.log "reqBody is"
		console.log reqBody

		# build query options
		reqopts = @baseRequestOptions
		reqopts.method = "POST"
		reqopts.path = apiPath
		reqopts.headers =
			"Accept" : "*/*"
			"Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8"

		# send query
		q = new httpreq(reqopts)
		q.query reqBody, (res2) =>
			data = res2.body or {}

			console.log(util.inspect(data, false, null))

			# validate response
			if not res2
				res.err = 'invalid response from amazon api'
				return cb(res) if cb
				return res.send 500

			return cb(res) if cb
			return res.send 200
	#}}}
	confirmBillingAgreement: (req, res, args, cb) => #{{{
		endpoint = @baseRequestOptions.host
		apiPath = @ApiPath
		timestamp = new Date().toISOString()

		amazonHeaders =
			AWSAccessKeyId: @AWSAccessKeyId
			Action: "ConfirmBillingAgreement"
			SellerId: @SellerId
			#MWSAuthToken: "amzn.mws.4ea38b7b-f563-7709-4bae-87aeaEXAMPLE"
			SignatureMethod: "HmacSHA256"
			SignatureVersion: "2"
			Timestamp: encodeURIComponent(timestamp) # 2013-12-11T10%3A57%3A18.000Z
			Version: "2013-01-01"

		amazonBody =
			AmazonBillingAgreementId: args.AmazonBillingAgreementId # C01-8824045-7416542

		combinedObject = {}
		Object.assign(combinedObject, amazonHeaders)
		Object.assign(combinedObject, amazonBody)

		stringToSign = "POST\n"
		stringToSign += endpoint + "\n"
		stringToSign += apiPath + "\n"
		stringToSign += @createStringToSign(combinedObject)

		hmac = crypto.createHmac('sha256', @ClientSecret)
		hmac.update(stringToSign)
		signature = hmac.digest('base64') # Z0ZVgWu0ICF4FLxt1mTjyK%2BjdYG6Kmm8JxLTfsQtKRY%3D

		#console.log "stringToSign is"
		#console.log stringToSign

		#console.log "signature is"
		#console.log signature

		reqBody = ""
		for key of amazonHeaders
			reqBody += key + "=" + amazonHeaders[key] + "&"
		for key of amazonBody
			reqBody += key + "=" + amazonBody[key] + "&"
		reqBody += 'Signature=' + encodeURIComponent(signature)

		console.log "reqBody is"
		console.log reqBody

		# build query options
		reqopts = @baseRequestOptions
		reqopts.method = "POST"
		reqopts.path = apiPath
		reqopts.headers =
			"Accept" : "*/*"
			"Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8"

		# send query
		q = new httpreq(reqopts)
		q.query reqBody, (res2) =>
			# validate response
			if not res2?.body?.ConfirmBillingAgreementResponse?.ConfirmBillingAgreementResult
				return res.send 500, 'invalid response from amazon api'

			return cb(res2.body) if cb
			return res.send 200
	#}}}
	authorizeOnBillingAgreement: (req, res, args, cb) => #{{{
		endpoint = @baseRequestOptions.host
		apiPath = "/OffAmazonPayments_Sandbox/2013-01-01"
		timestamp = new Date().toISOString()

		amazonHeaders =
			AWSAccessKeyId: @AWSAccessKeyId
			Action: "AuthorizeOnBillingAgreement"
			SellerId: @SellerId
			#MWSAuthToken: "amzn.mws.4ea38b7b-f563-7709-4bae-87aeaEXAMPLE"
			SignatureMethod: "HmacSHA256"
			SignatureVersion: "2"
			Timestamp: encodeURIComponent(timestamp) # 2013-12-11T10%3A57%3A18.000Z
			Version: "2013-01-01"

		amazonBody =
			AmazonBillingAgreementId: args.AmazonBillingAgreementId # C01-8824045-7416542
			"AuthorizationAmount.Amount": args.price # 59.99
			"AuthorizationAmount.CurrencyCode": args.currency # USD
			"AuthorizationReferenceId": args.authorizationReference
			"SellerOrderAttributes.CustomInformation": args.userId
			"CaptureNow": true
			"TransactionTimeout": 0

		combinedObject = {}
		Object.assign(combinedObject, amazonHeaders)
		Object.assign(combinedObject, amazonBody)

		stringToSign = "POST\n"
		stringToSign += endpoint + "\n"
		stringToSign += apiPath + "\n"
		stringToSign += @createStringToSign(combinedObject)

		hmac = crypto.createHmac('sha256', @ClientSecret)
		hmac.update(stringToSign)
		signature = hmac.digest('base64') # Z0ZVgWu0ICF4FLxt1mTjyK%2BjdYG6Kmm8JxLTfsQtKRY%3D

		#console.log "stringToSign is"
		#console.log stringToSign

		#console.log "signature is"
		#console.log signature

		reqBody = ""
		for key of amazonHeaders
			reqBody += key + "=" + amazonHeaders[key] + "&"
		for key of amazonBody
			reqBody += key + "=" + amazonBody[key] + "&"
		reqBody += 'Signature=' + encodeURIComponent(signature)

		console.log "reqBody is"
		console.log reqBody

		# build query options
		reqopts = @baseRequestOptions
		reqopts.method = "POST"
		reqopts.path = apiPath
		reqopts.headers =
			"Accept" : "*/*"
			"Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8"

		# send query
		q = new httpreq(reqopts)
		q.query reqBody, (res2) =>
			state = res2?.body?.AuthorizeOnBillingAgreementResponse?.AuthorizeOnBillingAgreementResult?[0]?.AuthorizationDetails?[0]?.AuthorizationStatus?[0]?.State?[0]
			# validate response
			if not state?
				return res.send 500, "Invalid response from Amazon API request"

			return cb(state) if cb
			# hmm
			return res.send 200
	#}}}

# vim: foldmethod=marker wrap
