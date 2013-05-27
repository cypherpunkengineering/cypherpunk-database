require '..'
require '../wizrsa'

fs = require 'fs'

key = wiz.framework.wizrsa.generateKeyPair()
if key
	fs.writeFileSync 'private.pem', wiz.framework.wizrsa.getPrivatePEMfromKey(key)
	fs.writeFileSync 'public.pem', wiz.framework.wizrsa.getPublicPEMfromKey(key)
	console.log 'keys written to filesystem'
else
	console.log 'key generation failure'

