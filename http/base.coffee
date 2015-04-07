# copyright 2013 J. Maurice <j@wiz.biz>

require '..'

wiz.package 'wiz.framework.http'

class wiz.framework.http.base
	debug: true
	constructor: () ->

	# error handler
	error: (e, cb) => #{{{
		wiz.log.err e
		return cb null if cb
		return null
	#}}}

	# to ssl or not to ssl
	client: () => #{{{ http or https object
		return (if @ssl is false then http else https)
	#}}}
	proto: () => #{{{ http or http string
		(if @ssl is false then 'http' else 'https')
	#}}}

# vim: foldmethod=marker wrap
