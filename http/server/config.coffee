# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'

wiz.package 'wiz.framework.http.server.config'

class wiz.framework.http.server.configBase #{{{ base http server config object

	# what IP/port to listen on
	listeners: [
		{ host: '127.0.0.1', port: 11080 }
	]

	# number of child processes to fork
	workers: 1

	# limit HTTP request size to prevent DoS frmo memory exhaustion
	maxRequestLimit: 1024 * 1024 * 2

#}}}

# vim: foldmethod=marker wrap
