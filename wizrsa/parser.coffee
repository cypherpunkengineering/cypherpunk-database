require '..'
require '../wizrsa'
rsa = require '../wizrsa/rsa'
require '../util/list'

wiz.package 'wiz.framework.wizrsa.parser'

class wiz.framework.wizrsa.parser.asnvalue extends wiz.framework.list.tree
	constructor: (@inBuffer) ->
		super()

	setValue: (inValue) =>
		@value = inValue

	getASNtag: (pos) =>
		tagByte = @inBuffer.slice(pos,1)
		return tagByte

	getASNsizeBufferLength: (pos) =>
		lengthByte = @inBuffer.readUInt8(pos)
		if lengthByte < 128
			# Return -1 if we don't need to advance position when reading sizebufferlength
			return -1
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
			throw "Invalid RSA Key"
		pos++
		sizeBufLength = @getASNsizeBufferLength(pos)
		# Don
		if sizeBufLength == -1
			# Don't advance position to read size buffer length which must be only 1 byte long
			sizeBufLength = 1
		else
			pos++
		size = @getASNvalueSize(pos, sizeBufLength)
		pos += sizeBufLength
		@value = @inBuffer.slice(pos, pos+size)
		@valueEndPosition = pos + size
		return

	toString: () =>
		@value.toString('hex')

	encode: () =>
		result = @type
		if @type == wiz.framework.wizrsa.TAG_BITSTRING
			@value = Buffer.concat([new Buffer('00', 'hex'), @value])
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

class wiz.framework.wizrsa.parser.keyPair extends wiz.framework.list.tree
	constructor: (@modulus, @publicExponent) ->
		super()

	encode: () =>
		v = new Buffer(0)
		n = @branchList.tail
		while n
			v = Buffer.concat([v,n.encode()])
			n = n.prev
		return v

	getModulus: () =>
		return @modulus

	getPublicExponent: () =>
		return @publicExponent

class wiz.framework.wizrsa.parser.privateKey extends wiz.framework.wizrsa.parser.keyPair
	constructor: (@modulus, @publicExponent, @privateExponent, @prime1, @prime2, @exponent1, @exponent2, @coefficient) ->
		super()

	@fromBuffer: (buffer) =>
		stringValue = buffer.toString("utf8")
		strippedString = @stripHeaderFooter(stringValue)
		keyBuffer = new Buffer(strippedString, 'base64')
		key = new wiz.framework.wizrsa.parser.privateKey()
		s1 = key.branchAdd(new wiz.framework.wizrsa.parser.sequence(keyBuffer))
		s1.parseValue()
		version = s1.branchAdd(new wiz.framework.wizrsa.parser.integer(s1.value))
		version.parseValue()
		modulus = s1.branchAdd(new wiz.framework.wizrsa.parser.integer(s1.value.slice(version.valueEndPosition,s1.value.length)))
		modulus.parseValue()
		publicExponent = s1.branchAdd(new wiz.framework.wizrsa.parser.integer(modulus.inBuffer.slice(modulus.valueEndPosition,modulus.inBuffer.length)))
		publicExponent.parseValue()
		privateExponent = s1.branchAdd(new wiz.framework.wizrsa.parser.integer(publicExponent.inBuffer.slice(publicExponent.valueEndPosition,publicExponent.inBuffer.length)))
		privateExponent.parseValue()
		prime1 = s1.branchAdd(new wiz.framework.wizrsa.parser.integer(privateExponent.inBuffer.slice(privateExponent.valueEndPosition,privateExponent.inBuffer.length)))
		prime1.parseValue()
		prime2 = s1.branchAdd(new wiz.framework.wizrsa.parser.integer(prime1.inBuffer.slice(prime1.valueEndPosition,prime1.inBuffer.length)))
		prime2.parseValue()
		exponent1 = s1.branchAdd(new wiz.framework.wizrsa.parser.integer(prime2.inBuffer.slice(prime2.valueEndPosition,prime2.inBuffer.length)))
		exponent1.parseValue()
		exponent2 = s1.branchAdd(new wiz.framework.wizrsa.parser.integer(exponent1.inBuffer.slice(exponent1.valueEndPosition,exponent1.inBuffer.length)))
		exponent2.parseValue()
		coefficient = s1.branchAdd(new wiz.framework.wizrsa.parser.integer(exponent2.inBuffer.slice(exponent2.valueEndPosition,exponent2.inBuffer.length)))
		coefficient.parseValue()
		key.modulus = modulus.value
		key.publicExponent = publicExponent.value
		key.privateExponent = privateExponent.value
		key.prime1 = prime1.value
		key.prime2 = prime2.value
		key.exponent1 = exponent1.value
		key.exponent2 = exponent2.value
		key.coefficient = coefficient.value
		return key

	@fromRSAkey: (privateKey) =>
		key = new wiz.framework.wizrsa.parser.privateKey()
		s1 = key.branchAdd(new wiz.framework.wizrsa.parser.sequence())
		version = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		version.setValue(new Buffer("00",'hex'))
		modulus = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		modulusHex = wiz.framework.wizrsa.doPaddingOnHexstring privateKey.n.toString(16)
		modulusIntBuf = new Buffer(modulusHex, 'hex')
		modulus.setValue(modulusIntBuf)
		publicExponent = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		publicExponentHex = wiz.framework.wizrsa.doPaddingOnHexstring privateKey.e.toString(16)
		publicExponentIntBuf = new Buffer(publicExponentHex, 'hex')
		publicExponent.setValue(publicExponentIntBuf)
		privateExponent = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		privateExponentHex = wiz.framework.wizrsa.doPaddingOnHexstring privateKey.d.toString(16)
		privateExponentIntBuf = new Buffer(privateExponentHex, 'hex')
		privateExponent.setValue(privateExponentIntBuf)
		prime1 = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		prime1Hex = wiz.framework.wizrsa.doPaddingOnHexstring privateKey.p.toString(16)
		prime1IntBuf = new Buffer(prime1Hex, 'hex')
		prime1.setValue(prime1IntBuf)
		prime2 = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		prime2Hex = wiz.framework.wizrsa.doPaddingOnHexstring privateKey.q.toString(16)
		prime2IntBuf = new Buffer(prime2Hex, 'hex')
		prime2.setValue(prime2IntBuf)
		exponent1 = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		exponent1Hex = wiz.framework.wizrsa.doPaddingOnHexstring privateKey.dmp1.toString(16)
		exponent1IntBuf = new Buffer(exponent1Hex, 'hex')
		exponent1.setValue(exponent1IntBuf)
		exponent2 = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		exponent2Hex = wiz.framework.wizrsa.doPaddingOnHexstring privateKey.dmq1.toString(16)
		exponent2IntBuf = new Buffer(exponent2Hex, 'hex')
		exponent2.setValue(exponent2IntBuf)
		coefficient = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		coefficientHex = wiz.framework.wizrsa.doPaddingOnHexstring privateKey.coeff.toString(16)
		coefficientIntBuf = new Buffer(coefficientHex, 'hex')
		coefficient.setValue(coefficientIntBuf)
		return key

	toPEMbuffer: () =>
		header = "-----BEGIN RSA PRIVATE KEY-----\n"
		footer = "-----END RSA PRIVATE KEY-----"
		publicPEM = rsa.linebrk(@encode().toString('base64'),64) + "\n"
		pemBuffer = new Buffer(header+publicPEM+footer)
		return pemBuffer

	@stripHeaderFooter: (stringValue) =>
		stringValue = stringValue.replace("-----BEGIN RSA PRIVATE KEY-----", "")
		stringValue = stringValue.replace("-----END RSA PRIVATE KEY-----", "")
		stringValue = stringValue.replace(/[\s\n]+/g, "")
		return stringValue

class wiz.framework.wizrsa.parser.publicKey extends wiz.framework.wizrsa.parser.keyPair

	@fromBuffer: (buffer) =>
		stringValue = buffer.toString("utf8")
		strippedString = @stripHeaderFooter(stringValue)
		keyBuffer = new Buffer(strippedString, 'base64')
		key = new wiz.framework.wizrsa.parser.publicKey()
		s1 = key.branchAdd(new wiz.framework.wizrsa.parser.sequence(keyBuffer))
		s1.parseValue()
		s2 = s1.branchAdd(new wiz.framework.wizrsa.parser.sequence(s1.value))
		s2.parseValue()
		oid1 = s2.branchAdd(new wiz.framework.wizrsa.parser.oid(s2.value))
		oid1.parseValue()
		null1 = s2.branchAdd(new wiz.framework.wizrsa.parser.nullobj(s2.value.slice(oid1.valueEndPosition,s2.value.length)))
		null1.parseValue()
		bs1 = s1.branchAdd(new wiz.framework.wizrsa.parser.bitstring(s1.value.slice(s2.valueEndPosition,s1.value.length)))
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

	@fromModulusExponent: (modulus, publicExponent) =>
		key = new wiz.framework.wizrsa.parser.publicKey(modulus, publicExponent)
		s1 = key.branchAdd(new wiz.framework.wizrsa.parser.sequence())
		s2 = s1.branchAdd(new wiz.framework.wizrsa.parser.sequence())
		oid1 = s2.branchAdd(new wiz.framework.wizrsa.parser.oid())
		oid1.setValue(new Buffer(wiz.framework.wizrsa.DER_ALGORITHM_ID, 'hex'))
		null1 = s2.branchAdd(new wiz.framework.wizrsa.parser.nullobj())
		null1.setValue(new Buffer(0))
		bs1 = s1.branchAdd(new wiz.framework.wizrsa.parser.bitstring())
		s3 = bs1.branchAdd(new wiz.framework.wizrsa.parser.sequence())
		i1 = s3.branchAdd(new wiz.framework.wizrsa.parser.integer)
		i1.setValue(modulus)
		i2 = s3.branchAdd(new wiz.framework.wizrsa.parser.integer)
		i2.setValue(publicExponent)
		return key

	toPEMbuffer: () =>
		header = "-----BEGIN PUBLIC KEY-----\n"
		footer = "-----END PUBLIC KEY-----"
		publicPEM = rsa.linebrk(@encode().toString('base64'),64) + "\n"
		pemBuffer = new Buffer(header+publicPEM+footer)
		return pemBuffer

	@stripHeaderFooter: (stringValue) =>
		stringValue = stringValue.replace("-----BEGIN PUBLIC KEY-----", "")
		stringValue = stringValue.replace("-----END PUBLIC KEY-----", "")
		stringValue = stringValue.replace(/[\s\n]+/g, "")
		return stringValue

class wiz.framework.wizrsa.parser.encapsulatingasn extends wiz.framework.wizrsa.parser.asnvalue
	encode: () =>
		v = new Buffer(0)
		#x = @each (f) =>
		n = @branchList.tail
		while n
			v = Buffer.concat([v,n.encode()])
			n = n.prev
		@value = v
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
#pubkey = fs.readFileSync 'public.pem'
#blah = wiz.framework.wizrsa.parser.publicKey.fromBuffer(pubkey)
#privkeybuf = fs.readFileSync 'private.pem'
#blah = wiz.framework.wizrsa.parser.privateKey.fromBuffer(privkeybuf)
privkey = new rsa.Key()
privkey.generate(2048, "10001")
#console.log privkey.n.toString(16).length
blah = wiz.framework.wizrsa.parser.privateKey.fromRSAkey(privkey)
#privkey.setPrivateEx(blah.modulus.toString('hex'),blah.publicExponent.toString('hex'),blah.privateExponent.toString('hex'),blah.prime1.toString('hex'),blah.prime2.toString('hex'),blah.exponent1.toString('hex'),blah.exponent2.toString('hex'),blah.coefficient.toString('hex'))
#console.log blah.modulus.toString('hex')
#console.log blah.publicExponent.toString('hex')
#pubkey = new rsa.Key()
#pubkey.generate(2048, "10001")
#console.log pubkey.n.toString(16).length
#modulus = wiz.framework.wizrsa.doPaddingOnHexstring pubkey.n.toString(16)
#modulusIntBuf = new Buffer(modulus, 'hex')
#exp = wiz.framework.wizrsa.doPaddingOnHexstring pubkey.e.toString(16)
#exponentIntBuf = new Buffer(exp, 'hex')
#blah = wiz.framework.wizrsa.parser.publicKey.fromModulusExponent(modulusIntBuf,exponentIntBuf)
#console.log blah.encode().toString('hex')
console.log blah.toPEMbuffer().toString('utf8')
