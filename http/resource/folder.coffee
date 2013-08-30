# copyright 2013 wiz technologies inc.

require '../..'
require './base'
require './mime'
require './static'

fs = require 'fs'

wiz.package 'wiz.framework.http.resource'

class wiz.framework.http.resource.folderListing extends wiz.framework.http.resource.base
	secure: true

	constructor: (@server, @parent, @path, @files) -> #{{{
		super(@server, @parent, @path)
	#}}}
	handler: (req, res) => #{{{
		return res.send(403, 'directory listing denied') if @secure

		res.setHeader('Content-Type', 'text/html')
		# TODO: implement directory listing
		res.end()
	#}}}

class wiz.framework.http.resource.folder extends wiz.framework.http.resource.base
	indexType: wiz.framework.http.resource.folderListing
	resourceType: wiz.framework.http.resource.static

	constructor: (@server, @parent, @path, @parentDir) -> #{{{
		super(@server, @parent, @path)
		@folderPath = @parentDir + '/' + @path + '/'
	#}}}

	init: () => #{{{ scan folder for files, add them to route list
		@files = []
		try
			#wiz.log.debug "scanning #{@folderPath}"
			@files = fs.readdirSync @folderPath
		catch e
			wiz.log.err "unable to open resource folder #{@path}: #{e}"

		@routeAdd new @indexType(@server, this, '', @files)
		@routeAdd new @resourceType(@server, this, f, @path + '/' + f) for f in @files
	#}}}
	handler: (req, res) => #{{{ redirect to trailing slash for directory listing
		@redirect(req, res, @getFullPath() + '/')
	#}}}

# vim: foldmethod=marker wrap
