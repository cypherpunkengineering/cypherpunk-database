require '..'
require '../wizrsa'

fs = require 'fs'

jasonpem =
	priv: fs.readFileSync 'jason/private.pem'
	pub: fs.readFileSync 'jason/public.pem'

#wiz.framework.wizrsa.loadPublicKeyFromPEM jasonpem.pub.toString()
#wiz.framework.wizrsa.generateKeypair 1024

key = wiz.framework.wizrsa.loadPrivateKeyFromPEMstr jasonpem.priv.toString()
keyout = wiz.framework.wizrsa.getPrivatePEMfromKey(key)

console.log jasonpem.priv.toString()
console.log keyout

