# copyright 2013 wiz technologies inc.

require '..'
require '../util/list'

wiz.package 'wiz.framework.http.router'

class wiz.framework.http.router extends wiz.framework.list.tree

	constructor: (@server, @parent, @path = '', @method = 'GET') -> #{{{
		super @parent
		@method = @method.toUpperCase() if @method
		@routeTable = {}
	#}}}
	init: () => #{{{
		# for child class
	#}}}

	routeAdd: (m) => #{{{
		wiz.log.debug "added router for #{m.getFullPath()}"
		wiz.log.debug "added handler for #{m.method} #{m.getFullPath()}" if m.handler?
		@routeTable[m.path] = m
		@branchAdd m
	#}}}

	redirect: (req, res, path = '/', numeric = 301) => #{{{ respond with a redirect to an absolute URL built from a given relative URL
		proto = (if req.secure then 'https' else 'http')

		if path and path[0..3] == 'http' # absolute url is given
			url = path
		else # relative url given, build absolute url
			url = proto + '://' + req?.headers?.host + path

		res.setHeader('Location', url)
		res.send(numeric)
	#}}}

	getFullPath: () => #{{{ recurse tree back to root to obtain full path
		path = @path
		parent = @parent
		while parent
			path = parent.path + '/' + path
			parent = parent.parent
		return path
	#}}}

# vim: foldmethod=marker wrap
