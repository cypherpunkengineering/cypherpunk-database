# copyright 2013 wiz technologies inc.

require '..'
require './server'

jade = require 'jade'
coffee = require 'coffee-script'
fs = require 'fs'

wiz.package 'wiz.framework.http.template'

class wiz.framework.http.template
	contentType: 'text/plain'
	templateFolder: '_text'
	templateExt: '.txt'
	compiler: () => () => ''
	content: null

	constructor: (@dir, @id, @options) -> #{{{ load template from file
		@path = @dir + '/' + @templateFolder + '/' + @id + @templateExt
	#}}}
	init: () => #{{{
		wiz.log.debug "loading template from #{@path}"

		try
			@src = fs.readFileSync @path
		catch e
			@src = null
			wiz.log.err "failed loading template #{@path}: #{e}"
	#}}}
	compile: () => #{{{
		try
			@renderer = @compiler()
		catch e
			@renderer = null
			wiz.log.err "failed compiling template #{@id}: #{e}"
	#}}}
	render: (args = {}) => #{{{
		try
			@content = @renderer args
		catch e
			@content = null
			wiz.log.err "failed rendering template #{@id}: #{e}"
	#}}}
	serve: (req, res) => #{{{ send rendered @content as http response
		@init() unless @src
		@compile() unless @renderer
		@render() unless @content
		res.setHeader 'Content-Type', @contentType
		res.setHeader 'Content-Length', @content.length
		res.end @content
	#}}}

class wiz.framework.http.coffeeScript extends wiz.framework.http.template
	contentType: 'application/ecmascript'
	templateFolder: '_coffee'
	templateExt: '.coffee'

	constructor: (@dir, @id, @options = {}) -> #{{{ load template from file
		super(@dir, @id, @options)
		@options.bare = true # don't add coffee-script's clojure wrapper
	#}}}
	init: () => #{{{ convert buffer to string
		super()
		@src = @src.toString()
	#}}}
	compiler: () => #{{{ compile using coffee-script
		@content = coffee.compile @src, @options
		return () =>
			return @content
	#}}}

class wiz.framework.http.jadeTemplate extends wiz.framework.http.template
	contentType: 'text/html'
	templateFolder: '_jade'
	templateExt: '.jade'

	constructor: (@dir, @id, @options = {}) -> #{{{ load template from file
		super(@dir, @id, @options)
		@options.pretty = true if wiz.style is 'DEV' # pretty print for developers
	#}}}
	compiler: () => #{{{ compile using jade
		jade.compile @src, @options
	#}}}

# vim: foldmethod=marker wrap
