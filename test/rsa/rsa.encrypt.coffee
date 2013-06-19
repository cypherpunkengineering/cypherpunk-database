require '..'
require '../rsa'

fs = require 'fs'

key = wiz.framework.rsa.generateKeyPair()
fs.writeFileSync 'private.pem', wiz.framework.rsa.getPrivatePEMfromKey(key)
fs.writeFileSync 'public.pem', wiz.framework.rsa.getPublicPEMfromKey(key)

text = 'hello one two three'

enc = key.encrypt(text)
encbuf = new Buffer(enc, 'hex')
console.log encbuf.toString('base64')
fs.writeFileSync 'enc.out', encbuf.toString('binary'), { encoding: 'binary' }

