require '../..'
require '../../http/server'
require '../../http/resource'
require '../../http/coffee-script'
require '../../http/jade'

fs = require 'fs'

wiz.app 'testor'

class text extends wiz.framework.http.router
	init: () =>
		@resource = new wiz.framework.http.resource.static __dirname, 'leet'
	handler: (req, res) =>
		@resource.serve req, res

class html extends wiz.framework.http.router
	init: () =>
		@resource = new wiz.framework.http.resource.jadeTemplate __dirname, 'leet'
	handler: (req, res) =>
		@resource.serve req, res

class ecmascript extends wiz.framework.http.router
	init: () =>
		@cs = new wiz.framework.http.resource.coffeeScript __dirname, 'leet'
	handler: (req, res) =>
		@cs.serve req, res

class server extends wiz.framework.http.server
	init: () =>
		@root.routeAdd new text(this, @root, 'text')
		@root.routeAdd new html(this, @root, 'html')
		@root.routeAdd new ecmascript(this, @root, 'ecmascript')
		super()

app = new server()
app.config.workers = 1
app.start()

# vim: foldmethod=marker wrap
