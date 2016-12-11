require '../..'
require '../../http/server/base'
require '../../http/resource/base'
require '../../http/resource/root'

wiz.app 'testor'

class level3 extends wiz.framework.http.resource.base
	handler: (req, res) =>
		res.send 200, 'you have reached level3'

class level2 extends wiz.framework.http.resource.base
	init: () =>
		@routeAdd new level3(@server, this, 'three')
		super()

	handler: (req, res) =>
		res.send 200, 'you have reached level2'

class level1 extends wiz.framework.http.resource.base
	handler: (req, res) =>
		res.send 200, 'you have reached level1'

class root extends wiz.framework.http.resource.root
	init: () =>
		@routeAdd new level1(@server, this, '')
		@routeAdd new level2(@server, this, 'two')
		super()

class server extends wiz.framework.http.server.base
	init: () =>
		@root = new root(this, null, '')
		super()

app = new server()
app.config.workers = 1
app.start()

# vim: foldmethod=marker wrap
