# copyright 2013 wiz technologies inc.

require '../..'

crypto = require 'crypto'
BigInteger = require '../../crypto/jsbn'

wiz.package 'wiz.framework.http.account.session'
wiz.sessions = {}

class wiz.framework.http.account.session
	@key: 'wiz.session'
	expires: 60 # minutes from now

	@load: (sid) => # load session from db after receiving request {{{
		return wiz.sessions[sid] || {}
	#}}}
	@save: (s) => # save session to db after sending response {{{
		wiz.sessions[s.sid] = s
		return true
	#}}}
	@middleware: (req, res) => # middleware to load session if cookie present {{{
		req.session = {}
		sid = req.cookies?[wiz.framework.http.account.session.key]
		req.session = wiz.framework.http.account.session.load(sid) if sid
		req.next()
	#}}}
	constructor: (req, res) -> # create new session {{{
		r = new BigInteger(crypto.randomBytes(64))
		@sid = wiz.framework.crypto.convert.biToBase32(r)
		@created = new Date()
		@cookie = wiz.framework.http.account.session.setCookie
			name: wiz.framework.http.account.session.key
			val: @sid
			path: '/'
			expires: new Date(@created.getTime() + (@expires * 1000))
			httpOnly: true
			secure: true

		res.setHeader 'Set-Cookie', @cookie
		req.session = this
	#}}}
	@setCookie: (opts) => #{{{
		# Set-Cookie: connect.sid=RBYBtQ8XYmaX9fr9DPcfKhUy.vzR8ey26fYG7sGJYHHUSzSWyJJO12e5jiW0BKdd3YsY; path=/; expires=Sun, 08 Sep 2013 14:03:51 GMT; httpOnly; secure
		pairs = [opts.name + '=' + encodeURIComponent(opts.val)]
		pairs.push 'expires=' + opts.expires.toUTCString() if opts.expires
		pairs.push 'domain=' + opts.domain if opts.domain
		pairs.push 'path=' + opts.path if opts.path
		pairs.push 'httpOnly' if opts.httpOnly
		pairs.push 'secure' if opts.secure
		return pairs.join('; ')
	#}}}

# vim: foldmethod=marker wrap
