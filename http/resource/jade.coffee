# copyright 2013 wiz technologies inc.

require '../..'
require './base'
require './static'
require './folder'

jade = require 'jade'

wiz.package 'wiz.framework.http.resource'

class wiz.framework.http.resource.jadeTemplate extends wiz.framework.http.resource.static
	contentType: 'text/html'
	dynamic: true

	constructor: (@server, @parent, @path, @file, @options = {}, @method) -> #{{{ load resource from file
		super(@server, @parent, @path, @file, @method)
		@options.pretty = true if wiz.style is 'DEV' # pretty print for developers
	#}}}
	compiler: () => #{{{ compile using jade
		jade.compile @src, @options
	#}}}

class wiz.framework.http.resource.jadeFolder extends wiz.framework.http.resource.folder
	resourceType: wiz.framework.http.resource.jadeTemplate

# vim: foldmethod=marker wrap
