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
	loading: false

	constructor: (@server, @parent, @path, @file, @method) -> #{{{
		super(@server, @parent, @path, @method)
		@args ?= {}
	#}}}
	init: () => #{{{ precompile on init
		super()
		@getContentType()
		@load (ok) =>
			return if not ok
			#wiz.log.debug "loaded file #{@file}"
			@compile()
	#}}}
	getContentType: () => #{{{
		if @contentType is null
			dots = @file.split('.')
			ext = dots[dots.length - 1]
			@contentType = wiz.framework.http.resource.mime.getType(ext)
	#}}}
	load: (cb) => #{{{ load src from filesystem
		return cb(false) if @loading
		#wiz.log.debug "loading file #{@file}"
		@loading = true
		@src = null
		fs.stat @file, (err, @stats) =>
			err = 'not a file' if @stats and not @stats.isFile()
			if err
				@stats = null
				@loading = false
				wiz.log.err "failed stating file #{@file}: #{err}"
				return cb(false)

			fs.readFile @file, (err, @src) =>
				@loading = false
				if err
					@src = null
					wiz.log.err "failed reading file #{@file}: #{err}"
					return cb(false)

				cb(true)
	#}}}
	compile: () => #{{{ returns function to render content
		try
			#wiz.log.debug "compiling file #{@file}"
			@renderer = @compiler()
			#wiz.log.debug "compiled file #{@file}"
		catch e
			@renderer = null
			wiz.log.err "failed compiling template #{@file}: #{e}"
	#}}}
	compiler: () => #{{{ return a function that returns rendered content
		() =>
			return @src
	#}}}
	render: () => #{{{ renders @content
		@compile() unless @renderer

		try
			#wiz.log.debug "rendering file #{@file}"
			@content = @renderer @args
			#wiz.log.debug "rendered file #{@file}"
		catch e
			@content = null
			wiz.log.err "failed rendering #{@file}: #{e}"
	#}}}
	handler: (req, res) => #{{{ send @content as http response
		@render() unless @content

		if @src is null or @renderer is null or @content is null
			wiz.log.err 'no content to serve'
			return res.send 500

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

			res.setHeader 'Last-Modified', @stats.mtime if @stats?.mtime

		res.setHeader 'Content-Type', @contentType if @contentType
		res.setHeader 'Content-Length', @content.length if @content?.length

		res.write(@content)

		res.end() if @final
	#}}}

# vim: foldmethod=marker wrap
