# copyright 2013 wiz technologies inc.

require '..'
require './server'

jade = require 'jade'
fs = require 'fs'

wiz.package 'wiz.framework.http.template'

class wiz.framework.http.template

	@loadFile: (dir, id, options = {}) -> #{{{ load template from file
		path = dir + '/_jade/' + id + '.jade'
		#wiz.log.debug "loading jade template from #{path}"

		try
			src = fs.readFileSync path
		catch e
			wiz.log.err "failed loading jade template #{path}: #{e}"
			return null

		t = new wiz.framework.http.template(id, src, options)
		t.compile()
		return t
	#}}}
	constructor: (@id, @src, @options) -> #{{{ private constructor
		@options.pretty = true if wiz.style is 'DEV'
		@content = null
		@jade = () -> {}
	#}}}

	compile: () => #{{{
		try
			@jade = jade.compile(@src, @options)
			return true
		catch e
			wiz.log.err "failed compiling jade template #{@id}: #{e}"
	#}}}
	render: (args = {}) => #{{{
		try
			@content = @jade(args)
		catch e
			@content = ''
			wiz.log.err "failed rendering jade template #{@id}: #{e}"

		return @content
	#}}}
	serve: (req, res) => #{{{
		@render() unless @content
		res.setHeader 'Content-Type', 'text/html'
		res.end @content
	#}}}

# vim: foldmethod=marker wrap
