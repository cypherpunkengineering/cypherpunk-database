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
		@valueEndPosition=pos+size
		return

class wiz.framework.wizrsa.parser.publicKey extends wiz.framework.list.tree

class wiz.framework.wizrsa.parser.sequence extends wiz.framework.wizrsa.parser.asnvalue
	type: wiz.framework.wizrsa.TAG_SEQUENCE

class wiz.framework.wizrsa.parser.bitstring extends wiz.framework.wizrsa.parser.asnvalue
	type: wiz.framework.wizrsa.TAG_BITSTRING

class wiz.framework.wizrsa.parser.integer extends wiz.framework.wizrsa.parser.asnvalue
	type: wiz.framework.wizrsa.TAG_INTEGER

class wiz.framework.wizrsa.parser.oid extends wiz.framework.wizrsa.parser.asnvalue
	type: wiz.framework.wizrsa.TAG_OID

class wiz.framework.wizrsa.parser.nullobj extends wiz.framework.wizrsa.parser.asnvalue
	type: wiz.framework.wizrsa.TAG_NULL

class wiz.framework.wizrsa.parser.parsePublicKey
	constructor: () ->
		@key = new wiz.framework.wizrsa.parser.publicKey()

	fromBuffer: (buffer) =>
		stringValue = buffer.toString("utf8")
		strippedString = @stripHeaderFooter(stringValue)
		keyBuffer = new Buffer(strippedString, 'base64')
		s1 = @key.branchAdd(new wiz.framework.wizrsa.parser.sequence(keyBuffer))
		s1.parseValue()
		s2 = @key.branchAdd(new wiz.framework.wizrsa.parser.sequence(keyBuffer.slice(s1.valueBeginPosition,keyBuffer.length)))
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
		@modulus = i1.value
		@publicExponent = i2.value


	getModulus: () =>
		return @modulus

	getPublicExponent: () =>
		return @publicExponent

	stripHeaderFooter: (stringValue) =>
		stringValue = stringValue.replace("-----BEGIN PUBLIC KEY-----", "")
		stringValue = stringValue.replace("-----END PUBLIC KEY-----", "")
		stringValue = stringValue.replace(/[\s\n]+/g, "")
		return stringValue


fs = require 'fs'
pubkey = fs.readFileSync 'public.pem'
blah = new wiz.framework.wizrsa.parser.parsePublicKey()
blah.fromBuffer(pubkey)
console.log "modulus " + blah.getModulus().toString('hex')
console.log "public exponent " + blah.getPublicExponent().toString('hex')


#oid1.value = 'foo'
#null1.value = null
#i1.value = 2048
#i2.value = 65537

#key.each (o) =>
#console.log o.type
