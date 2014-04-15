# copyright 2013 wiz technologies inc.

require '../..'
require './base'

wiz.package 'wiz.framework.http.resource.root'

class wiz.framework.http.resource.root extends wiz.framework.http.resource.base

	init: () => #{{{
		@each (r) =>
			wiz.log.debug "loading router #{r.getFullPath()}"
			r.load()
		@each (r) =>
			wiz.log.debug "init router #{r.getFullPath()}"
			r.init()
	#}}}

	handler403: (req, res) => #{{{ default 403 handler
		res.send 403, 'forbidden'
	#}}}
	handler404: (req, res) => #{{{ default 404 handler
		res.send 404, 'not found'
	#}}}
	handler500: (req, res, err) => #{{{ default 500 handler
		wiz.log.err err
		res.send 500, 'server error'
	#}}}

# vim: foldmethod=marker wrap
