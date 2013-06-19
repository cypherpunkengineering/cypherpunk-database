require '../..'
require '../../rsa'

fs = require 'fs'

x509 = 'wiz.crt'
console.log "reading #{x509}"

x509buffer = fs.readFileSync x509
if x509buffer
	console.log 'x509 read from filesystem'
else
	console.log 'x509 read failure'

if x509buffer
	key = wiz.framework.rsa.root.fromBuffer(x509buffer)
	key.printTree()
