# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require './base'
require './mime'
require './static'

fs = require 'fs'

wiz.package 'wiz.framework.http.resource'

class wiz.framework.http.resource.folderListing extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.public
	secure: true

	constructor: (@server, @parent, @path, @files) -> #{{{
		super(@server, @parent, @path)
	#}}}
	handler: (req, res) => #{{{
		return res.send(403, 'directory listing denied') if @secure
		res.send 200, @files
	#}}}

class wiz.framework.http.resource.folder extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.public
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
					r = new @constructor(@server, this, f, @folderPath)
					wiz.log.debug "recursing into folder #{r.getFullPath()}"
					@routeAdd(r)
					r.init()
				else if stat.isFile()
					r = new @resourceType(@server, this, f, @folderPath + '/' + f)
					wiz.log.debug "adding resource #{r.getFullPath()}"
					@routeAdd(r)
					r.init()
	#}}}
	handler: (req, res) => #{{{ redirect to trailing slash for directory listing
		@redirect(req, res, @getFullPath() + '/')
	#}}}

# vim: foldmethod=marker wrap
