require '../..'
require '../../http/server/base'
require '../../http/resource/base'
require '../../http/resource/root'
require '../../http/resource/coffee-script'
require '../../http/resource/jade'

fs = require 'fs'

wiz.app 'testor'

class server extends wiz.framework.http.server.base
	init: () =>
		@root = new wiz.framework.http.resource.root this, null, ''
		@root.routeAdd new wiz.framework.http.resource.coffeeFolder(this, @root, '_coffee', __dirname)
		@root.routeAdd new wiz.framework.http.resource.jadeFolder(this, @root, '_jade', __dirname)
		@root.routeAdd new wiz.framework.http.resource.folder(this, @root, 'stuff', __dirname)
		super()

app = new server()
app.config.workers = 1
app.start()

# vim: foldmethod=marker wrap
