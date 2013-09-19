# copyright 2013 wiz technologies inc.

require '../..'
require './base'
require './static'
require './folder'

coffee = require 'coffee-script'

wiz.package 'wiz.framework.http.resource'

class wiz.framework.http.resource.coffeeScript extends wiz.framework.http.resource.static
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.public
	contentType: 'application/ecmascript'

	constructor: (@server, @parent, @path, @file, @options = {}, @method) -> #{{{ load resource from file
		super(@server, @parent, @path, @file, @method)
		@options.bare = true # don't add coffee-script's clojure wrapper
	#}}}
	compiler: () => #{{{ compile using coffee-script
		@content = coffee.compile @src.toString(), @options

		return () =>
			return @content
	#}}}

class wiz.framework.http.resource.coffeeFolder extends wiz.framework.http.resource.folder
	resourceType: wiz.framework.http.resource.coffeeScript

# vim: foldmethod=marker wrap
