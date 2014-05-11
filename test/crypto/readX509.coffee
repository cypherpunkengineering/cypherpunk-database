require '../..'
require '../../crypto'

fs = require 'fs'

wiz.app 'foo'

x509 = 'wiz.crt'
console.log "reading #{x509}"

x509buffer = fs.readFileSync x509
if x509buffer
	console.log 'x509 read from filesystem'
else
	console.log 'x509 read failure'

if x509buffer
	crt = wiz.framework.crypto.base.fromBuffer(x509buffer)
	console.log crt
	for c in crt
		c.printTree()
