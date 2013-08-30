# copyright 2013 wiz technologies inc.

require '../..'
require './base'
require './folder'

coffee = require 'coffee-script'

wiz.package 'wiz.framework.http.resource'

class wiz.framework.http.resource.coffeeScript extends wiz.framework.http.resource.base
	contentType: 'application/ecmascript'

	constructor: (@server, @parent, @path, @file, @options = {}, @method) -> #{{{ load resource from file
		super(@server, @parent, @path, @file, @method)
		@options.bare = true # don't add coffee-script's clojure wrapper
	#}}}
	load: () => #{{{ convert buffer to string
		super()
		@src = @src.toString()
	#}}}
	compiler: () => #{{{ compile using coffee-script
		@content = coffee.compile @src, @options
		return () =>
			return @content
	#}}}

class wiz.framework.http.resource.coffeeFolder extends wiz.framework.http.resource.folder
	resourceType: wiz.framework.http.resource.coffeeScript

# vim: foldmethod=marker wrap
