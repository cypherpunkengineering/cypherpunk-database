require '..'
require '../rsa'

fs = require 'fs'

text = 'hello one two three'
keyfiles =
	pub: fs.readFileSync 'public.pem'

key = wiz.framework.rsa.loadPublicKeyFromPEMstr keyfiles.pub.toString()
if key
	console.log 'key read from filesystem'
else
	console.log 'key read failure'

enc = key.encrypt(text)
if enc
	console.log 'text encrypted'
else
	console.log 'encryption failure'

encbuf = new Buffer(enc, 'hex')
fs.writeFileSync 'enc.out', encbuf.toString('binary'), { encoding: 'binary' }

console.log 'encrypted text written to filesystem'
