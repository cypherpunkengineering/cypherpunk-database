require '..'
require '../wizrsa'

fs = require 'fs'

key = wiz.framework.wizrsa.generateKeyPair()
fs.writeFileSync 'private.pem', wiz.framework.wizrsa.getPrivatePEMfromKey(key)
fs.writeFileSync 'public.pem', wiz.framework.wizrsa.getPublicPEMfromKey(key)

console.log key.n.bitLength()

