require '../..'
require '../../crypto'

fs = require 'fs'

wiz.app 'test'

text = fs.readFileSync 'in'

pubkey = fs.readFileSync 'public.2048.pem'

key = wiz.framework.crypto.fromBuffer(pubkey)

if enc = key[0].encrypt(text.toString())
	encbuf = new Buffer(enc, 'hex')
	fs.writeFileSync 'out', encbuf.toString('binary'), { encoding: 'binary' }
	console.log 'wiz encrypt OK'
else
	console.log 'wiz encrypt FAIL'
