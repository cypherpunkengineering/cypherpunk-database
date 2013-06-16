# copyright 2013 wiz technologies inc.

require '..'
require './server'

jade = require 'jade'
fs = require 'fs'

wiz.package 'wiz.framework.http.template'

class wiz.framework.http.template extends wiz.framework.http.router
	precompileFile: (path, options = {}) =>
		src = fs.readFileSync('leet.jade')
		@precompile(src, options)
		@compile()

	precompile: (src, options = {}) =>
		options.pretty = true if wiz.style is 'DEV'
		@jade = jade.compile(src, options)

	compile: (src, args = {}) =>
		@content = @jade(args)

	handler: (req, res) =>
		res.setHeader 'Content-Type', 'text/html'
		res.end @content

# vim: foldmethod=marker wrap
