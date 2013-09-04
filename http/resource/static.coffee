# copyright 2013 wiz technologies inc.

require '../..'
require './base'
require './mime'

fs = require 'fs'

wiz.package 'wiz.framework.http.resource'

class wiz.framework.http.resource.static extends wiz.framework.http.resource.base
	contentType: null
	content: null
	renderer: null
	final: true
	dynamic: false

	constructor: (@server, @parent, @path, @file, @method) -> #{{{
		super(@server, @parent, @path, @method)
	#}}}
	load: () => #{{{ load src from filesystem
		wiz.log.debug "reading file #{@file}"

		# FIXME: change all file i/o to async
		try
			@src = fs.readFileSync @file
			@stats = fs.statSync @file
		catch e
			@src = null
			@stats = null
			wiz.log.err "failed reading file #{@file}: #{e}"

		try
			ext = @file.split('.')
			@contentType = wiz.framework.http.mime.getType ext[ext.length - 1] unless @contentType
		catch e
			@contentType = null unless @contentType
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

		if not @dynamic
			# FIXME: check etag header and if-none-match
			notModified = undefined
			if req.headers?['if-modified-since']?
				try
					ims = new Date(req.headers['if-modified-since'])
					lmt = new Date(@stats.mtime)
					notModified = (ims - lmt == 0)
				catch e
					wiz.log.debug "unable to compare last modified time and if-modified-since headers: #{e}"

			# send 304 if cache is up to date
			if notModified
				return res.send 304

			res.setHeader 'Last-Modified', @stats.mtime if @stats and @stats.mtime

		res.setHeader 'Content-Type', @contentType if @contentType
		res.setHeader 'Content-Length', @content.length if @content and @content.length

		res.write @content

		res.end() if @final
	#}}}

# vim: foldmethod=marker wrap
