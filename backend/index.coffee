# wizportal web interface
# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/wiz/base'
require './server'
require './serverConfig'

wiz.app 'cypherpunk-web-backend'

class backend extends wiz.base
	main: () =>
		server = new cypherpunk.backend.server.main()
		server.config = new cypherpunk.backend.server.config()
		server.main()

app = new backend()
app.start()

# vim: foldmethod=marker wrap
