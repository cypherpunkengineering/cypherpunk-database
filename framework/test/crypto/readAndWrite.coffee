require '../..'
require '../../rsa'

fs = require 'fs'

keyfile = process.argv[2] or 'private.pem'
console.log "reading #{keyfile}"

privkeybuffer = fs.readFileSync keyfile
if privkeybuffer
	console.log 'key read from filesystem'
else
	console.log 'key read failure'

if privkeybuffer
	privkey = wiz.framework.crypto.rsa.root.fromBuffer privkeybuffer
	pubkey = wiz.framework.crypto.rsa.publicKey.fromPrivateKey privkey

if privkey
	fs.writeFileSync 'private.pem', privkey.toPEMbuffer()
	console.log 'private key written to filesystem'

if pubkey
	fs.writeFileSync 'public.pem', pubkey.toPEMbuffer()
	console.log 'public key written to filesystem'
else
	console.log 'key write failure'
