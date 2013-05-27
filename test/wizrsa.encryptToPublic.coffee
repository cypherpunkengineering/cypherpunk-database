require '..'
require '../wizrsa'

fs = require 'fs'

keyfiles =
	pub: fs.readFileSync 'public.pem'

key = wiz.framework.wizrsa.loadPublicKeyFromPEMstr keyfiles.pub.toString()

console.log keyfiles.pub.toString()

console.log wiz.framework.wizrsa.getPublicPEMfromKey(key)

text = 'hello one two three'

enc = key.encrypt(text)
encbuf = new Buffer(enc, 'hex')
console.log encbuf.toString('base64')
fs.writeFileSync 'enc.out', encbuf.toString('binary'), { encoding: 'binary' }
