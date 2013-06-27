require '../..'
require '../../crypto/rsa'

fs = require 'fs'
proc = require 'child_process'

lengths = [
#	42
#	512
#	1024
#	1337
	2048
	#4096
]

checkRSA = (len) ->
	proc.exec "openssl rsa -in private.#{len}.pem -check -noout", (err, stdout, stderr) =>
		return console.log 'fail' if err
		console.log "checking #{len} bit private key using openssl"
		console.log stdout

checkASN = (len) ->
	proc.exec "openssl asn1parse -in public.#{len}.pem", (err, stdout, stderr) =>
		return console.log 'fail' if err
		console.log "checking #{len} bit private key using openssl"
		console.log stdout

	proc.exec "openssl asn1parse -in public.#{len}.pem", (err, stdout, stderr) =>
		return console.log 'fail' if err
		console.log "checking #{len} bit public key using openssl"
		console.log stdout

for len in lengths
	key = wiz.framework.rsa.key.generateKeypair(len)

	if not key
		console.log len + 'bit keypair generation failure'
		return

	fs.writeFileSync "private.#{len}.pem", key.private.toPEMbuffer()
	fs.writeFileSync "public.#{len}.pem", key.public.toPEMbuffer()
	console.log len + 'bit keypair written to filesystem'
	checkASN(len)
	checkRSA(len)
