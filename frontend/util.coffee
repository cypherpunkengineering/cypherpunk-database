# copyright 2013 J. Maurice <j@wiz.biz>
require '..'

http = require("http")
crypto = require("crypto")
parse = require("url").parse

wiz.package 'wiz.framework.frontend.util'

class wiz.framework.frontend.util

	@hasBody = (req) ->
		"transfer-encoding" of req.headers or req.headers["content-length"] isnt "0"

	@mime = (req) ->
		str = req.headers["content-type"] or ""
		str.split(";")[0]

	@error = (code, msg) ->
		err = new Error(msg or http.STATUS_CODES[code])
		err.status = code
		err

	@md5 = (str, encoding) ->
		crypto.createHash("md5").update(str).digest encoding or "hex"

	@merge = (a, b) ->
		if a and b
			for key of b
				a[key] = b[key]
		a

	@escape = (html) ->
		String(html).replace(/&(?!\w+;)/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace /"/g, "&quot;"

	@uid = (len) ->
		crypto.randomBytes(Math.ceil(len * 3 / 4)).toString("base64").slice(0, len).replace(/\//g, "-").replace /\+/g, "_"

	@parseJSONCookies = (obj) ->
		Object.keys(obj).forEach (key) ->
			val = obj[key]
			res = @parseJSONCookie(val)
			obj[key] = res	if res

		obj

	@parseJSONCookie = (str) ->
		if 0 is str.indexOf("j:")
			try
				return JSON.parse(str.slice(2))

	@removeContentHeaders = (res) ->
		Object.keys(res._headers).forEach (field) ->
			res.removeHeader field	if 0 is field.indexOf("content")


	@conditionalGET = (req) ->
		req.headers["if-modified-since"] or req.headers["if-none-match"]

	@unauthorized = (res, realm) ->
		res.statusCode = 401
		res.setHeader "WWW-Authenticate", "Basic realm=\"" + realm + "\""
		res.end "Unauthorized"

	@notModified = (res) ->
		@removeContentHeaders res
		res.statusCode = 304
		res.end()

	@etag = (stat) ->
		"\"" + stat.size + "-" + Number(stat.mtime) + "\""

	@parseCacheControl = (str) ->
		directives = str.split(",")
		obj = {}
		i = 0
		len = directives.length

		while i < len
			parts = directives[i].split("=")
			key = parts.shift().trim()
			val = parseInt(parts.shift(), 10)
			obj[key] = (if isNaN(val) then true else val)
			i++
		obj

	@parseUrl = (req) ->
		parsed = req._parsedUrl
		if parsed and parsed.href is req.url
			parsed
		else
			req._parsedUrl = parse(req.url)

# vim: foldmethod=marker wrap
