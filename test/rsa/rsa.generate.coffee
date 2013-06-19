require '../..'
require '../../rsa'

fs = require 'fs'

key = wiz.framework.rsa.key.generateKeypair()

if key
	fs.writeFileSync 'private.pem', key.private.toPEMbuffer()
	# fs.writeFileSync 'public.pem', key.public.toPEMbuffer()
	console.log 'keys written to filesystem'
else
	console.log 'key generation failure'

