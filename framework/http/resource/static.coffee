# copyright 2013 J. Maurice <j@wiz.biz>

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
	cache: true
	log: false
	clone: null # to clone a pre-compiled renderer to save time
	debugCompile: false

	constructor: (@server, @parent, @path, @file, @method) -> #{{{
		super(@server, @parent, @path, @method)
		@args ?= {}
	#}}}
	init: () => #{{{ preload and precompile on init
		return if @clone # skip init, we will just call clone's methods

		@getContentType()
		@cache = false if wiz.style is 'DEV' # disable cache during development
		@loader (ok) =>
			wiz.log.err "initial loading of #{@file} failed" if not ok
	#}}}

	getContentType: () => #{{{
		if @contentType is null
			dots = @file.split('.')
			ext = dots[dots.length - 1]
			@contentType = wiz.framework.http.resource.mime.getType(ext)
	#}}}

	loader: (cb) => #{{{ load if necessary

		necessary = false
		necessary = true if not @src # initial load or previous loading error
		necessary = true if not @cache # cache is disabled for this resource

		return cb(true) if not necessary

		oldmtime = @stats?.mtime?.getTime() # save old mtime
		@stat (statOK) => # stat file to see if it's newer than our cache
			return cb(false) if not statOK # error while stat'ing

			necessary = false if @stats?.mtime?.getTime() == oldmtime # file unchanged
			return cb(true) if not necessary

			# ness, ness, ness... necessary to load file
			wiz.log.debug "re-loading #{@file}" if @src

			@read (readOK) =>
				#wiz.log.debug "reading #{@file}"
				return cb(false) if not readOK
				@content = null
				@compile()
				return cb(@renderer?)
	#}}}
	stat: (cb) => #{{{ get file stats
		wiz.assert(@file, "invalid @file for #{@getFullPath()}")
		#wiz.log.debug "stating file #{@file}"
		fs.stat @file, (err, @stats) =>
			err = 'not a file' if @stats and not @stats.isFile()
			return cb(true) if not err
			@stats = null
			wiz.log.err "failed stating path #{@getFullPath()} file #{@file}: #{err}"
			return cb(false)
	#}}}
	read: (cb) => #{{{ read src from filesystem
		wiz.log.debug "re-reading file #{@file}" if @content
		fs.readFile @file, (err, @src) =>
			return cb(true) if not err
			@src = null
			wiz.log.err "failed reading file #{@file}: #{err}"
			return cb(false)
	#}}}

	compile: () => #{{{ returns function to render content
		if @renderer
			wiz.log.debug "re-compiling path #{@getFullPath()} from file #{@file}"
		else
			wiz.log.debug "compiling path #{@getFullPath()} from file #{@file}" if @debug or @debugCompile
		try
			@renderer = @compiler()
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

		#wiz.log.debug "rendering file #{@file}"
		try
			@content = @renderer @args
		catch e
			@content = null
			wiz.log.err "failed rendering #{@file}: #{e}"
	#}}}

	handler: (req, res) => #{{{ send @content as http response
		return @clone.handler(req, res) if @clone

		@loader (ok) =>

			if not ok
				err = 'error loading file'
				wiz.log.err err
				return res.send 500, err

			@render(req, res) if @dynamic or not @content

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
