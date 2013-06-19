require '..'
require '../rsa'

fs = require 'fs'

key = wiz.framework.rsa.generateKeyPair()
fs.writeFileSync 'private.pem', wiz.framework.rsa.getPrivatePEMfromKey(key)
fs.writeFileSync 'public.pem', wiz.framework.rsa.getPublicPEMfromKey(key)

console.log key.n.bitLength()

