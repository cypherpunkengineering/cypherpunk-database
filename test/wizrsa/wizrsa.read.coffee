require '..'
require '../wizrsa'

fs = require 'fs'

keyfile = process.argv[2] or 'private.pem'
x509 = 'wiz.pem'
#console.log "reading #{keyfile}"
console.log "reading #{x509}"

privkey = fs.readFileSync keyfile
if privkey
	console.log 'key read from filesystem'
else
	console.log 'key read failure'

x509buffer = fs.readFileSync x509
if x509buffer
	console.log 'x509 read from filesystem'
else
	console.log 'x509 read failure'

#if privkey
	#key = wiz.framework.wizrsa.parser.fromBuffer(privkey)
	#key = wiz.framework.wizrsa.main.loadPrivateKeyFromPEMbuffer(privkey)

if x509buffer
	key = wiz.framework.wizrsa.parser.fromBuffer(x509buffer)
	key.printTree()

#if key
	#fs.writeFileSync 'private.pem', key.toPEMbuffer()
	#fs.writeFileSync 'public.pem', wiz.framework.wizrsa.getPublicPEMfromKey(key)
	console.log 'key written to filesystem'
else
	console.log 'key write failure'
