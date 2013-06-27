require '../..'
require '../../rsa'

fs = require 'fs'

keyfiles =
	priv: fs.readFileSync 'private.2048.pem'
	pub: fs.readFileSync 'public.2048.pem'

key = wiz.framework.rsa.root.fromBuffer keyfiles.priv

text = fs.readFileSync 'enc.out'

enctext = text.toString('hex')

dec = key.decrypt(enctext)
if dec
	console.log dec.toString('ascii')
else
	console.log 'decryption failed'
