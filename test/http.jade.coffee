require '..'
require '../http/server'
require '../http/template'

fs = require 'fs'

wiz.app 'testor'

class level1 extends wiz.framework.http.template
	init: () =>
		@precompileFile 'leet.jade'

class server extends wiz.framework.http.server
	init: () =>
		@root.routeAdd new level1(this, @root, '')
		super()

app = new server()
app.config.workers = 1
app.start()

# vim: foldmethod=marker wrap
