require '..'
require '../http/server'

wiz.app 'testor'

class level3 extends wiz.framework.http.router
	handler: (req, res) =>
		res.write 'you have reached level3'
		res.end()

class level2 extends wiz.framework.http.router
	init: () =>
		@branchAdd new level3(@server, this, 'three', 'get', null, null, null)

	handler: (req, res) =>
		res.write 'you have reached level2'
		res.end()

class level1 extends wiz.framework.http.router
	init: () =>
		@branchAdd new level2(@server, this, 'two', 'get', null, null, null)

class server extends wiz.framework.http.server
	init: () =>
		@root.branchAdd new level1(this, @root, 'one')
		super()

app = new server()
app.config.workers = 1
app.start()

# vim: foldmethod=marker wrap
