require '../..'
require '../../crypto'

fs = require 'fs'

plaintext = fs.readFileSync 'in'
enctext = fs.readFileSync 'out'

privkey = fs.readFileSync 'private.2048.pem'
key = wiz.framework.crypto.fromBuffer(privkey)

dectext = key[0].decrypt(enctext.toString('hex'))

if (dectext.toString() != plaintext.toString())
	console.log 'wiz decrypt FAIL'
else
	console.log 'wiz decrypt OK'
