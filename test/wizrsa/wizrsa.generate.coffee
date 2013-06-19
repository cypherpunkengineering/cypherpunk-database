require '..'
require '../wizrsa'

fs = require 'fs'

key = wiz.framework.wizrsa.main.generateKeyPair()
if key
	fs.writeFileSync 'private.pem', wiz.framework.wizrsa.main.getPrivatePEMfromKey(key)
	#fs.writeFileSync 'public.pem', wiz.framework.wizrsa.main.getPublicPEMfromKey(key)
	console.log 'keys written to filesystem'
else
	console.log 'key generation failure'

