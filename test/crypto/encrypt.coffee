require '../..'
require '../../crypto/rsa'

fs = require 'fs'

text = 'hello one two three'

keyfiles =
	pub: fs.readFileSync 'public.2048.pem'

key = wiz.framework.rsa.key.fromBuffer keyfiles.pub

if key
	console.log 'key read from filesystem'
else
	console.log 'key read failure'

enc = key.encrypt(text)
if enc
	console.log 'text encrypted'
else
	console.log 'encryption failure'

encbuf = new Buffer(enc, 'hex')
fs.writeFileSync 'enc.out', encbuf.toString('binary'), { encoding: 'binary' }

console.log 'encrypted text written to filesystem'

proc = require 'child_process'
proc.exec "openssl rsautl -inkey private.2048.pem -decrypt -in enc.out", (err, stdout, stderr) =>
	if err
		console.log 'openssl decryption failed: '+err
		return

	if stdout == text
		console.log 'decryption successful, strings match'
	else
		console.log 'strings do not match'
