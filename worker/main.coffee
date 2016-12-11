# wiz manager daemon reference implementation
# copyright 2014 J. Maurice <j@wiz.biz>

# framework
require './daemon'

cypherpunkBackendDaemon = new cypherpunk.backend.daemon()
cypherpunkBackendDaemon.init()

# vim: foldmethod=marker wrap
