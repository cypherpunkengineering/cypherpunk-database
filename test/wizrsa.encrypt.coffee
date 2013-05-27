require '..'
require '../wizrsa'

fs = require 'fs'

key = wiz.framework.wizrsa.generateKeyPair()
fs.writeFileSync 'private.pem', wiz.framework.wizrsa.getPrivatePEMfromKey(key)
fs.writeFileSync 'public.pem', wiz.framework.wizrsa.getPublicPEMfromKey(key)

text = 'hello one two three'

enc = key.encrypt(text)
encbuf = new Buffer(enc, 'hex')
console.log encbuf.toString('base64')
fs.writeFileSync 'enc.out', encbuf.toString('binary'), { encoding: 'binary' }

