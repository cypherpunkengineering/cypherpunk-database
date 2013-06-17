require '../..'
require '../../http/server'
require '../../http/template'

fs = require 'fs'

wiz.app 'testor'

class resource extends wiz.framework.http.router
	init: () =>
		@template = wiz.framework.http.template.loadFile(__dirname, 'leet')
	handler: (req, res) =>
		@template.serve req, res

class server extends wiz.framework.http.server
	init: () =>
		@root.routeAdd new resource(this, @root, '')
		super()

app = new server()
app.config.workers = 1
app.start()

# vim: foldmethod=marker wrap
