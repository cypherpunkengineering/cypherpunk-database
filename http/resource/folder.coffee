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
		res.send 200, @files
	#}}}

class wiz.framework.http.resource.folder extends wiz.framework.http.resource.base
	indexType: wiz.framework.http.resource.folderListing
	resourceType: wiz.framework.http.resource.static

	constructor: (@server, @parent, @path, @parentDir) -> #{{{
		super(@server, @parent, @path)
		@folderPath = @parentDir
		@folderPath += '/' if @parentDir[@parentDir.length-1] != '/'
		@folderPath += @path
	#}}}

	init: () => #{{{ scan folder for files, add them to route list
		@files = []
		wiz.log.debug "scanning #{@folderPath}"
		fs.readdir @folderPath, (err, @files) =>
			if err
				wiz.log.err "unable to open resource folder #{@path}: #{err}"
				super()
				return

			@routeAdd new @indexType(@server, this, '', @files)
			for f in @files
				stat = fs.statSync(@folderPath + '/' + f)
				if stat.isDirectory()
					@routeAdd new @constructor(@server, this, f, @folderPath)
				else if stat.isFile()
					@routeAdd new @resourceType(@server, this, f, @folderPath + '/' + f)
			super()
	#}}}
	handler: (req, res) => #{{{ redirect to trailing slash for directory listing
		@redirect(req, res, @getFullPath() + '/')
	#}}}

# vim: foldmethod=marker wrap
