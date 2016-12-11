# wizportal web interface
# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './server'
require './serverConfig'

wiz.app 'wizportal'

server = new cypherpunk.backend.server.main()
server.config = new cypherpunk.backend.server.config()
server.main()

# vim: foldmethod=marker wrap
