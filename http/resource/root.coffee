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
		root = req.route.server.root

		for route of root.routeTable
			resources = []
			continue unless module = root.routeTable[route]
			if module.isVisible(req)
				#console.log module.title

				for r of module.routeTable
					continue unless resource = module.routeTable[r]
					if resource.isVisible(req)
						#console.log resource.title
						resources.push
							title: resource.title
							path: resource.getFullPath()

				req.nav[module.path] =
					title: module.title
					path: module.getFullPath()
					resources: resources
					resourceCount: resources.length

		req.next()
	#}}}

# vim: foldmethod=marker wrap
