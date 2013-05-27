require '..'
require '../wizrsa'

fs = require 'fs'

keyfiles =
	priv: fs.readFileSync 'private.pem'
	pub: fs.readFileSync 'public.pem'

key = wiz.framework.wizrsa.loadPrivateKeyFromPEMstr keyfiles.priv.toString()

text = fs.readFileSync 'enc.out'
enctext = text.toString('hex')

dec = key.decrypt(enctext)
console.log dec.toString('ascii')
