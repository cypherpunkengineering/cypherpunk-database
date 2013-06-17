# copyright 2013 wiz technologies inc.

require '..'

fs = require 'fs'

wiz.package 'wiz.framework.http.resource'

class wiz.framework.http.resource.static
	contentFolder: '_text'
	contentFileExt: '.txt'
	contentType: 'text/plain'
	content: null
	renderer: null
	final: true

	constructor: (@parentDir, @id, @options) -> #{{{
		@path = @parentDir + '/' + @contentFolder + '/' + @id + @contentFileExt
	#}}}
	load: () => #{{{ load src from filesystem
		wiz.log.debug "reading file #{@path}"

		try
			@src = fs.readFileSync @path
		catch e
			@src = null
			wiz.log.err "failed reading file #{@path}: #{e}"
	#}}}
	compile: () => #{{{
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
	render: (args) => #{{{
		@compile() unless @renderer
		try
			@content = @renderer args
		catch e
			@content = null
			wiz.log.err "failed rendering #{@id}: #{e}"
	#}}}
	serve: (req, res) => #{{{ send @content as http response
		@load() unless @src
		@render() unless @content
		res.setHeader 'Content-Type', @contentType
		res.setHeader 'Content-Length', @content.length
		if @final
			res.end @content
		else
			res.write @content
	#}}}

# vim: foldmethod=marker wrap
