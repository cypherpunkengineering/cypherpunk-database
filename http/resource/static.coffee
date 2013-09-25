# copyright 2013 wiz technologies inc.

require '../..'
require './base'
require './mime'
require './power'

fs = require 'fs'

wiz.package 'wiz.framework.http.resource'

class wiz.framework.http.resource.static extends wiz.framework.http.resource.base
	# default to public/stranger access
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.public
	contentType: null
	content: null
	renderer: null
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
	render: (req, res) => #{{{ renders @content
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
		if @dynamic or not @content
			@render(req, res)

		if @src is null or @renderer is null or @content is null
			wiz.log.err 'no content to serve'
			return res.send 500

		if not @dynamic
			# set last-modified header for static content
			res.setHeader 'Last-Modified', @stats.mtime if @stats?.mtime

			# check if-modified-since header is older than 
			if req.headers?['if-modified-since']?
				try
					# if modified since
					ims = new Date(req.headers['if-modified-since'])
					# last modified time
					lmt = new Date(@stats.mtime)

					# FIXME: maybe this should be greater than instead of equal to??
					notModified = (ims - lmt == 0)
				catch e
					wiz.log.debug "unable to compare last modified time and if-modified-since headers: #{e}"
					notModified = undefined # lol i dunno

			# TODO: check etag header and if-none-match

			# send 304 if cache is up to date
			return res.send 304 if notModified

		res.setHeader 'Content-Type', @contentType if @contentType
		res.send 200, @content
	#}}}

# vim: foldmethod=marker wrap
