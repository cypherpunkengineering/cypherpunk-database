require '../..'
require '../../crypto'

fs = require 'fs'

wiz.app 'foo'

blobs = 'blobs.pem'
console.log "reading #{blobs}"

buf = fs.readFileSync blobs
if buf
	console.log 'blobs read from filesystem'
else
	console.log 'blobs read failure'

if buf
	blobs = wiz.framework.crypto.fromBuffer(buf)
	for b in blobs
		console.log 'found a blob'
		console.log ''
		console.log 'tree:'
		b.printTree()
		console.log ''
