require '..'
require '../wizrsa'
require '../util/list'

wiz.package 'wiz.framework.wizrsa.parser'

class wiz.framework.wizrsa.parser.asnvalue extends wiz.framework.list.tree
	constructor: (@inBuffer) ->
		super()

	getASNtag: (pos) =>
		tagByte = @inBuffer.slice(pos,1)
		return tagByte

	getASNsizeBufferLength: (pos) =>
		lengthByte = @inBuffer.readUInt8(pos)
		if lengthByte < 128
			return 1
		sizeBufLength = lengthByte - 0x80
		return sizeBufLength

	getASNvalueSize: (pos, sizeBufLength) =>
		sizeBuf = @inBuffer.slice(pos, pos+sizeBufLength)
		size = parseInt(sizeBuf.toString('hex'), 16)
		return size

	parseValue: () =>
		pos = 0
		tagByte = @getASNtag(pos)
		if tagByte.toString('hex') != @type.toString('hex')
			throw "Invalid RSA Public Key"
		pos++
		sizeBufLength = @getASNsizeBufferLength(pos)
		if sizeBufLength > 1
			pos++
		size = @getASNvalueSize(pos, sizeBufLength)
		pos += sizeBufLength
		@value = @inBuffer.slice(pos, pos+size)
		@rawSize = tagByte.length + sizeBufLength + size
		@valueBeginPosition=pos
		@valueEndPosition = pos + size
		return

	toString: () =>
		@value.toString('hex')

	encode: () =>
		result = @type
		if @value
			size = @value.length
		else
			size = 0

		# Calculate how many bytes are needed to store the value of size
		if size < 127 
			sizehex = new Buffer("0" + size.toString(16), "hex")
			result = Buffer.concat([result, sizehex])
		else
			hexstring = size.toString(16)

			# pads the hexstring to always have even number of bytes
			hexstring = "0" + hexstring if hexstring.length % 2 is 1

			# create new buffer
			sizeBuf = new Buffer(hexstring, "hex")
			# 0x80 + (2 or 3)
			firstByte = 0x80 + sizeBuf.length
			fb = new Buffer(firstByte.toString(16), "hex")
			result = Buffer.concat([result, fb, sizeBuf])

		result = Buffer.concat([result, @value])
		return result

class wiz.framework.wizrsa.parser.publicKey extends wiz.framework.list.tree
	constructor: (@modulus, @publicExponent) ->
		super()

	@fromBuffer: (buffer) =>
		stringValue = buffer.toString("utf8")
		strippedString = @stripHeaderFooter(stringValue)
		keyBuffer = new Buffer(strippedString, 'base64')
		key = new wiz.framework.wizrsa.parser.publicKey()
		s1 = key.branchAdd(new wiz.framework.wizrsa.parser.sequence(keyBuffer))
		s1.parseValue()
		s2 = key.branchAdd(new wiz.framework.wizrsa.parser.sequence(keyBuffer.slice(s1.valueBeginPosition,keyBuffer.length)))
		s2.parseValue()
		oid1 = s2.branchAdd(new wiz.framework.wizrsa.parser.oid(s2.value))
		oid1.parseValue()
		null1 = s2.branchAdd(new wiz.framework.wizrsa.parser.nullobj(s2.value.slice(oid1.valueEndPosition,s2.value.length)))
		null1.parseValue()
		pos = s2.rawSize
		bs1 = s1.branchAdd(new wiz.framework.wizrsa.parser.bitstring(s1.value.slice(s2.rawSize,keyBuffer.length)))
		bs1.parseValue()
		s3 = bs1.branchAdd(new wiz.framework.wizrsa.parser.sequence(bs1.value.slice(1,bs1.value.length)))
		s3.parseValue()
		i1 = s3.branchAdd(new wiz.framework.wizrsa.parser.integer(s3.value))
		i1.parseValue()
		i2 = s3.branchAdd(new wiz.framework.wizrsa.parser.integer(s3.value.slice(i1.valueEndPosition,s3.value.length)))
		i2.parseValue()
		key.modulus = i1.value
		key.publicExponent = i2.value
		return key

	@stripHeaderFooter: (stringValue) =>
		stringValue = stringValue.replace("-----BEGIN PUBLIC KEY-----", "")
		stringValue = stringValue.replace("-----END PUBLIC KEY-----", "")
		stringValue = stringValue.replace(/[\s\n]+/g, "")
		return stringValue

	encode: () =>
		v = new Buffer(0)
		@each (f) =>
			v = Buffer.concat([v,f.encode()])
		return v

	getModulus: () =>
		return @modulus

	getPublicExponent: () =>
		return @publicExponent

class wiz.framework.wizrsa.parser.encapsulatingasn extends wiz.framework.wizrsa.parser.asnvalue
	encode: () =>
		v = ''
		x = @each (f) =>
			v += f.encode()
		super()

class wiz.framework.wizrsa.parser.sequence extends wiz.framework.wizrsa.parser.encapsulatingasn
	type: wiz.framework.wizrsa.TAG_SEQUENCE



class wiz.framework.wizrsa.parser.bitstring extends wiz.framework.wizrsa.parser.encapsulatingasn
	type: wiz.framework.wizrsa.TAG_BITSTRING

class wiz.framework.wizrsa.parser.integer extends wiz.framework.wizrsa.parser.asnvalue
	type: wiz.framework.wizrsa.TAG_INTEGER

class wiz.framework.wizrsa.parser.oid extends wiz.framework.wizrsa.parser.asnvalue
	type: wiz.framework.wizrsa.TAG_OID

class wiz.framework.wizrsa.parser.nullobj extends wiz.framework.wizrsa.parser.asnvalue
	type: wiz.framework.wizrsa.TAG_NULL

class wiz.framework.wizrsa.parser.parsePublicKey


fs = require 'fs'
pubkey = fs.readFileSync 'public.pem'
blah = wiz.framework.wizrsa.parser.publicKey.fromBuffer(pubkey)
console.log blah.encode().toString('hex')
#console.log "modulus " + blah.getModulus().toString('hex')
#console.log "public exponent " + blah.getPublicExponent().toString('hex')


#oid1.value = 'foo'
#null1.value = null
#i1.value = 2048
#i2.value = 65537

#key.each (o) =>
#console.log o.type
