# copyright 2013 wiz technologies inc.

require '..'
require './server'
require './mime'

fs = require 'fs'

wiz.package 'wiz.framework.http.resource'

class wiz.framework.http.resource.static extends wiz.framework.http.router
	contentType: null
	content: null
	renderer: null
	final: true

	constructor: (@server, @parent, @path, @file) -> #{{{
		super(@server, @parent, @path)
	#}}}
	load: () => #{{{ load src from filesystem
		wiz.log.debug "reading file #{@file}"

		try
			@src = fs.readFileSync @file
		catch e
			@src = null
			wiz.log.err "failed reading file #{@file}: #{e}"

		try
			ext = @file.split('.')
			@contentType = wiz.framework.http.mime.getType ext[ext.length - 1]
		catch e
			@contentType = null
	#}}}
	compile: () => #{{{ returns function to render content
		try
			@renderer = @compiler()
		catch e
			@renderer = null
			wiz.log.err "failed compiling template #{@id}: #{e}"
	#}}}
	compiler: () => #{{{ return a function that returns rendered content
		() =>
			return @src
	#}}}
	render: (args) => #{{{ renders @content
		@compile() unless @renderer
		try
			@content = @renderer args
		catch e
			@content = null
			wiz.log.err "failed rendering #{@id}: #{e}"
	#}}}
	handler: (req, res) => #{{{ send @content as http response
		@load() unless @src
		@render() unless @content
		res.setHeader 'Content-Type', @contentType if @contentType
		res.setHeader 'Content-Length', @content.length if @content and @content.length
		if @final
			res.end @content
		else
			res.write @content
	#}}}

class wiz.framework.http.resource.folder extends wiz.framework.http.router
	resourceType: wiz.framework.http.resource.static

	constructor: (@server, @parent, @path, @parentDir) -> #{{{
		super(@server, @parent, @path)
	#}}}
	init: () => #{{{ scan folder for files, add them to route list
		console.log "scanning #{@path}"
		try
			files = fs.readdirSync @path
		catch e
			wiz.log.err "unable to open resource folder #{@path}: #{e}"
		for f in files
			fullPath = @parentDir + '/' + @path + '/' + f
			@routeAdd new @resourceType(@server, this, f, fullPath)
	#}}}

# vim: foldmethod=marker wrap
