require '../..'
require '../../crypto'

fs = require 'fs'

wiz.app 'test'

privkey = fs.readFileSync 'private.2048.pem'

plaintext = fs.readFileSync 'in'

key = wiz.framework.crypto.fromBuffer(privkey)

if signature = key[0].sign(plaintext)
	#console.log 'signature: ' + signature.toString('hex')
	fs.writeFileSync 'out', signature
	console.log 'wiz sign OK'
else
	console.log 'wiz sign FAIL'

