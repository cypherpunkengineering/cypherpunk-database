require '../..'
require '../../crypto'

fs = require 'fs'

wiz.app 'test'

signedtext = fs.readFileSync 'in'
signature = fs.readFileSync 'out'

pubkey = fs.readFileSync 'public.2048.pem'
key = wiz.framework.crypto.base.fromBuffer(pubkey)

if key[0].verify(signedtext, signature.toString('hex'))
	console.log 'wiz verify OK'
else
	console.log 'wiz verify FAIL'

