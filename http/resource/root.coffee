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
	@usernav: (req, res) => #{{{
		req.nav ?= {}
		req.nav ?= {}
		#console.log "path is #{req.route.path}"
		for route of req.route.parent.routeTable
			continue unless n = req.route.parent.routeTable[route]
			if n.isVisible(req)
				req.nav[n.path] =
					title: n.title
					path: n.getFullPath()

		#console.log req.nav
		req.next()
	#}}}

# vim: foldmethod=marker wrap
