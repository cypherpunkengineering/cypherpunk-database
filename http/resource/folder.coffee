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
	folderType: null
	indexType: null
	indexFile: null # index.html
	resourceType: wiz.framework.http.resource.static
	htmlSuffixOptional: true

	constructor: (@server, @parent, @path, @parentDir) -> #{{{
		super(@server, @parent, @path)
		@folderPath = @parentDir
		@folderPath += '/' if @parentDir[@parentDir.length-1] != '/'
		@folderPath += @path
	#}}}

	init: () => #{{{ scan folder for files, add them to route list
		# hack
		@folderType = wiz.framework.http.resource.folder if @folderType is null

		@files = []
		#wiz.log.debug "scanning #{@folderPath}"
		fs.readdir @folderPath, (err, @files) =>
			if err
				wiz.log.err "unable to open resource folder #{@path}: #{err}"
				super()
				return

			# add directory index
			@initIndex()

			# recurse thru files list
			@initFiles()
	#}}}
	initFiles: () => #{{{ recurse thru files list
		for f in @files
			stat = fs.statSync(@folderPath + '/' + f)
			if stat.isDirectory()
				@addFolder(@folderType, f) if @filterFolders(f)
			else if stat.isFile()
				@addFile(@resourceType, f) if @filterFiles(f)
	#}}}
	initIndex: () => #{{{ add directory index
		if @indexType
			index = new @indexType(@server, this, '', @files)
			@routeAdd(index)
			index.init()
		else if @indexFile
			index = new wiz.framework.http.resource.static(@server, this, '', @folderPath + '/' + @indexFile)
			@routeAdd(index)
			index.init()
	#}}}

	newFolder: (folderType, server, parent, file, folderPath) => #{{{
		return new folderType(server, parent, file, folderPath)
	#}}}
	newFile: (resourceType, server, parent, file, folderPath) => #{{{
		return new resourceType(server, parent, file, folderPath)
	#}}}

	addFolder: (folderType, f) => #{{{
		r = @newFolder(folderType, @server, this, f, @folderPath)
		#wiz.log.debug "recursing into folder #{r.getFullPath()}"
		@routeAdd(r)
		r.init()
	#}}}
	addFile: (resourceType, f, verbose = false) => #{{{
		r = @newFile(resourceType, @server, this, f, @folderPath + '/' + f)
		wiz.log.debug "adding resource #{r.getFullPath()}" if verbose
		@routeAdd(r)
		r.init()
		if @htmlSuffixOptional and f.split('.').pop() == 'html'
			nosuffix = f.slice(0, -5)
			r = @newFile(resourceType, @server, this, nosuffix, @folderPath + '/' + f)
			wiz.log.debug "adding html suffix optional route for #{r.getFullPath()}" if verbose
			@routeAdd(r)
			r.init()
	#}}}

	filterFolders: (fn) => #{{{ return true or false to allow this file resource being added
		return true
	#}}}
	filterFiles: (fn) => #{{{ return true or false to allow this file resource being added
		return true
	#}}}

	handler: (req, res) => #{{{ redirect to trailing slash for directory listing
		@redirect(req, res, @getFullPath() + '/')
	#}}}

# vim: foldmethod=marker wrap
