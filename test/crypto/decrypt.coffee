require '../..'
require '../../crypto/rsa'

fs = require 'fs'

text = "hello one two three\n"
proc = require 'child_process'
proc.exec "echo 'hello one two three' | openssl rsautl -encrypt -inkey public.2048.pem -pubin -out enc.out", (err, stdout, stderr) =>

keyfiles =
	priv: fs.readFileSync 'private.2048.pem'

enctext = fs.readFileSync 'enc.out'
key = wiz.framework.rsa.key.fromBuffer keyfiles.priv

dectext = key.decrypt(enctext.toString('hex'))

if dectext
	console.log dectext.toString('ascii')
if (dectext.toString('ascii') != text)
	console.log 'decryption failed'
else
	console.log 'decryption succeeded'
