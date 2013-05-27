require '..'
require '../wizrsa'

fs = require 'fs'

key = wiz.framework.wizrsa.generateKeyPair()
pubout = wiz.framework.wizrsa.getPublicPEMfromKey(key)
privout = wiz.framework.wizrsa.getPrivatePEMfromKey(key)

console.log pubout
console.log privout

