# copyright 2013 wiz technologies inc.

require '..'
require './resource'

jade = require 'jade'

wiz.package 'wiz.framework.http.resource'

class wiz.framework.http.resource.jadeTemplate extends wiz.framework.http.resource.static
	contentType: 'text/html'
	contentFolder: '_jade'
	contentFileExt: '.jade'

	constructor: (@dir, @id, @options = {}) -> #{{{ load resource from file
		super(@dir, @id, @options)
		@options.pretty = true if wiz.style is 'DEV' # pretty print for developers
	#}}}
	compiler: () => #{{{ compile using jade
		jade.compile @src, @options
	#}}}

# vim: foldmethod=marker wrap
