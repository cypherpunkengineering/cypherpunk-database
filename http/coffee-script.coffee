# copyright 2013 wiz technologies inc.

require '..'
require './resource'

coffee = require 'coffee-script'

wiz.package 'wiz.framework.http.resource'

class wiz.framework.http.resource.coffeeScript extends wiz.framework.http.resource.static
	contentType: 'application/ecmascript'
	contentFolder: '_coffee'
	contentFileExt: '.coffee'

	constructor: (@dir, @id, @options = {}) -> #{{{ load resource from file
		super(@dir, @id, @options)
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

# vim: foldmethod=marker wrap
