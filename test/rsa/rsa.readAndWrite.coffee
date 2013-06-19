require '..'
require '../rsa'

fs = require 'fs'

keyfile = process.argv[2] or 'private.pem'
console.log "reading #{keyfile}"

privkey = fs.readFileSync keyfile
if privkey
	console.log 'key read from filesystem'
else
	console.log 'key read failure'

if privkey
	key = wiz.framework.rsa.loadPrivateKeyFromPEMstr privkey.toString()

if key
	fs.writeFileSync 'private.pem', wiz.framework.rsa.getPrivatePEMfromKey(key)
	fs.writeFileSync 'public.pem', wiz.framework.rsa.getPublicPEMfromKey(key)
	console.log 'key written to filesystem'
else
	console.log 'key write failure'
