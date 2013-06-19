require '..'
require '../wizrsa'
require '../util/list'

rsa = require '../wizrsa/rsa'

wiz.package 'wiz.framework.wizrsa.parser'

class wiz.framework.wizrsa.parser
	@PRIVATE_KEY_HEADER = "-----BEGIN RSA PRIVATE KEY-----"
	@PUBLIC_KEY_HEADER = "-----BEGIN PUBLIC KEY-----"
	@X509_HEADER = "-----BEGIN CERTIFICATE-----"

	constructor: () ->

	@fromBuffer: (inBuffer) =>
		stringValue = inBuffer.toString("utf8")
		headerLength = stringValue.indexOf('\n')
		header = stringValue.substr(0, headerLength)
		switch header
			when @PRIVATE_KEY_HEADER then parserKey = new wiz.framework.wizrsa.parser.privateKey()
			when @PUBLIC_KEY_HEADER then parserKey = new wiz.framework.wizrsa.parser.publicKey()
			when @X509_HEADER then parserKey = new wiz.framework.wizrsa.parser.certificate()
			else return null
		strippedString = parserKey.stripHeaderFooter(stringValue)
		outBuffer = new Buffer(strippedString, 'base64')
		key = @parseBuffer(outBuffer, parserKey)
		#key.setValues()
		return key

	@parseBuffer: (inBuffer, currentBranch, position=0, depth='') =>
		while (position < inBuffer.length)
			slice = inBuffer.slice(position)
			newBranch = currentBranch.branchAdd(wiz.framework.wizrsa.parser.asnnode.fromBuffer(slice))
			#console.log newBranch.type.description
			if newBranch.type.container
				@parseBuffer(newBranch.getValueBuffer(), newBranch, 0, depth+"   ")
			position += newBranch.getNodeSize()
		return currentBranch

class wiz.framework.wizrsa.parser.asnnode extends wiz.framework.list.tree
	class nodeType
		constructor: (@tag, @description, @container = false) ->

	class scopeType
		constructor: (@scope, @description) ->

	@scopeTypes:
		0b00000000:	new scopeType(0b00000000, "UNIVERSAL")
		0b01000000:	new scopeType(0b01000000, "APPLICATION")
		0b10000000:	new scopeType(0b10000000, "CONTEXT")
		0b11000000:	new scopeType(0b11000000, "PRIVATE")

	@universalTypes:

		0x00: new nodeType(0x00, 'basic encoding rule header')
		0x01: new nodeType(0x01, 'boolean')
		0x02: new nodeType(0x02, 'integer')
		0x03: new nodeType(0x03, 'bit string', true)
		0x04: new nodeType(0x04, 'octet string', true)
		0x05: new nodeType(0x05, 'null')
		0x06: new nodeType(0x06, 'object identifier')
		0x07: new nodeType(0x07, 'ObjectDescriptor')
		0x08: new nodeType(0x08, 'instance of/external')
		0x09: new nodeType(0x09, 'real')
		0x0A: new nodeType(0x0A, 'enumerated')
		0x0B: new nodeType(0x0B, 'enumerated')
		0x0C: new nodeType(0x0C, 'utf8string')
		0x0D: new nodeType(0x0D, 'relative-oid')
		0x10: new nodeType(0x10, 'sequence', true)
		0x11: new nodeType(0x11, 'set, set of', true)
		0x12: new nodeType(0x12, 'numeric string')
		0x13: new nodeType(0x13, 'printable string')
		0x14: new nodeType(0x14, 'teletex string')
		0x15: new nodeType(0x15, 'videotex string')
		0x16: new nodeType(0x16, 'ia5string')
		0x17: new nodeType(0x17, 'utctime')
		0x18: new nodeType(0x18, 'GeneralizedTime')
		0x19: new nodeType(0x19, 'GraphicString')
		0x1A: new nodeType(0x1A, 'VisibleString, ISO64String')
		0x1B: new nodeType(0x1B, 'GeneralString')
		0x1C: new nodeType(0x1C, 'UniversalString')
		0x1D: new nodeType(0x1D, 'character string')
		0x1E: new nodeType(0x1E, 'BMPString')

	constructor: (@scope, @type, @inBuffer) ->
		super()

	@fromBuffer: (inBuffer) =>
		tagBuffer = wiz.framework.wizrsa.parser.asnnode.getASNtag(inBuffer)
		tagInt = tagBuffer.readUInt8(0)
		tag = tagInt & 0b00011111
		scopeInt = tagInt & 0b11000000
		scope = @scopeTypes[scopeInt]
		switch scope.description
			when "UNIVERSAL"
				type = @universalTypes[tag]
			else
				type = new nodeType(tag, "[#{tag}]")

		if not type?
			console.log 'invalid asn tag value: '+ tag
			return null

		n = new wiz.framework.wizrsa.parser.asnnode(scope, type, inBuffer)
		return n

	setValue: (inValue) =>
		@value = inValue

	@getASNtag: (inBuffer) =>
		tagByte = inBuffer.slice(0,1)
		return tagByte

	getASNsizeBufferLength: () =>
		# Size buffer length should always be 1 byte
		lengthByte = @inBuffer.slice(1,2).readUInt8(0)
		if lengthByte < 128
			# Return -1 if we don't need to advance position when reading sizebufferlength
			return -1
		sizeBufLength = lengthByte - 0x80
		return sizeBufLength

	getASNvalueSize: () =>
		sizeBufferLength = @getASNsizeBufferLength()
		if sizeBufferLength == -1
			sizeBuf = @inBuffer.slice(1,2)
		else 
			sizeBuf = @inBuffer.slice(2, 2+sizeBufferLength)
		size = parseInt(sizeBuf.toString('hex'), 16)
		return size

	getValueBuffer: () =>
		sizeBufSize = @getASNsizeBufferLength()
		valueSize = @getASNvalueSize()
		if sizeBufSize == -1
			value = @inBuffer.slice(2,2+valueSize)
		else
			value = @inBuffer.slice(2+sizeBufSize,2+sizeBufSize+valueSize)
		return value

	getNodeSize: () =>
		size = @getASNsizeBufferLength()
		if size < 0
			size = 1
		else
			size++
		size += @getASNvalueSize() + 1
		return size

	toString: () =>
		@value.toString('hex')

	printTree: (depthString = "") =>
		n = @branchList.tail
		printList = [ '13', '82', '86' ]
		while n
			if n.type.container
				console.log depthString + n.type.description
				n.printTree(depthString + "   ")
			else
				if printList.indexOf(n.type.tag.toString(16)) != -1
					console.log depthString + n.type.description + " " + n.getValueBuffer().toString('utf8')
				else
					console.log depthString + n.type.description
			n = n.prev

	encode: () =>
		result = @tag
		valueBuffer = @getValueBuffer()
		if @tag == wiz.framework.wizrsa.parser.asnnode.nodeTypes.BITSTRING
			valueBuffer = Buffer.concat([new Buffer('00', 'hex'), valueBuffer])
		if valueBuffer
			size = valueBuffer.length
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

		result = Buffer.concat([result, valueBuffer])
		return result

class wiz.framework.wizrsa.parser.key extends wiz.framework.list.tree
	constructor: (@modulus, @publicExponent) ->
		super()

	@createPublicKeyFromRSAkey: (publicKey) =>
		key = new wiz.framework.wizrsa.parser.key()
		s1 = key.branchAdd(new wiz.framework.wizrsa.parser.sequence())
		s2 = s1.branchAdd(new wiz.framework.wizrsa.parser.sequence())
		oid1 = s2.branchAdd(new wiz.framework.wizrsa.parser.oid())
		oid1.setValue(new Buffer(wiz.framework.wizrsa.main.DER_ALGORITHM_ID, 'hex'))
		null1 = s2.branchAdd(new wiz.framework.wizrsa.parser.nullobj())
		null1.setValue(new Buffer("00",'hex'))
		bs1 = s1.branchAdd(new wiz.framework.wizrsa.parser.bitstring())
		s3 = bs1.branchAdd(new wiz.framework.wizrsa.parser.sequence())
		modulus = s3.branchAdd(new wiz.framework.wizrsa.parser.integer())
		modulusHex = wiz.framework.wizrsa.main.doPaddingOnHexstring key.n.toString(16)
		modulusIntBuf.setValue(new Buffer(modulusHex,'hex'))
		publicExponent = s3.branchAdd(new wiz.framework.wizrsa.parser.integer())
		publicExponentHex = wiz.framework.wizrsa.main.doPaddingOnHexstring key.e.toString(16)
		publicExponentIntBuf = new Buffer(publicExponentHex,'hex')
		return key

	encode: () =>
		v = new Buffer(0)
		n = @branchList.tail
		while n
			v = Buffer.concat([v,n.encode()])
			n = n.prev
		return v

	printTree: (depthString = "") =>
		n = @branchList.tail
		while n
			if n.type.container
				console.log n.type.description
				n.printTree("   ")
			else
				console.log depthString + n.type.description
			n = n.prev

	getModulus: () =>
		return @modulus

	getPublicExponent: () =>
		return @publicExponent

class wiz.framework.wizrsa.parser.privateKey extends wiz.framework.wizrsa.parser.key
	constructor: (@modulus, @publicExponent, @privateExponent, @prime1, @prime2, @exponent1, @exponent2, @coefficient) ->
		super()

	@fromBuffer: (buffer) =>
		stringValue = buffer.toString("utf8")
		strippedString = @stripHeaderFooter(stringValue)
		keyBuffer = new Buffer(strippedString, 'base64')
		key = new wiz.framework.wizrsa.parser.privateKey()
		wiz.framework.wizrsa.parser.parseBuffer(keyBuffer, key)
		key.setValues()
		return key

	setValues: () =>
		list = [
				"modulus"
				"publicExponent"
				"privateExponent"
				"prime1"
				"prime2"
				"exponent1"
				"exponent2"
				"coefficient"
				]
		n = @branchList.tail
		i = 0
		@tailEach (n) =>
			if (!n.type.container)
				this[list[i]] = n.getValueBuffer()
				#console.log n.getValueBuffer().toString('hex')
				i++
		@modulus = this[list["modulus"]]
		@publicExponent = this[list["publicExponent"]]
		@privateExponent = this[list["privateExponent"]]
		@prime1 = this[list["prime1"]]
		@prime2 = this[list["prime2"]]
		@exponent1 = this[list["exponent1"]]
		@exponent2 = this[list["exponent2"]]
		@coefficient = this[list["coefficient"]]


	@fromRSAkey: (privateKey) =>
		key = new wiz.framework.wizrsa.parser.privateKey()
		s1 = key.branchAdd(new wiz.framework.wizrsa.parser.sequence())
		version = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		version.setValue(new Buffer("00",'hex'))
		modulus = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		modulusHex = wiz.framework.wizrsa.main.doPaddingOnHexstring privateKey.n.toString(16)
		modulusIntBuf = new Buffer(modulusHex, 'hex')
		modulus.setValue(modulusIntBuf)
		publicExponent = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		publicExponentHex = wiz.framework.wizrsa.main.doPaddingOnHexstring privateKey.e.toString(16)
		publicExponentIntBuf = new Buffer(publicExponentHex, 'hex')
		publicExponent.setValue(publicExponentIntBuf)
		privateExponent = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		privateExponentHex = wiz.framework.wizrsa.main.doPaddingOnHexstring privateKey.d.toString(16)
		privateExponentIntBuf = new Buffer(privateExponentHex, 'hex')
		privateExponent.setValue(privateExponentIntBuf)
		prime1 = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		prime1Hex = wiz.framework.wizrsa.main.doPaddingOnHexstring privateKey.p.toString(16)
		prime1IntBuf = new Buffer(prime1Hex, 'hex')
		prime1.setValue(prime1IntBuf)
		prime2 = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		prime2Hex = wiz.framework.wizrsa.main.doPaddingOnHexstring privateKey.q.toString(16)
		prime2IntBuf = new Buffer(prime2Hex, 'hex')
		prime2.setValue(prime2IntBuf)
		exponent1 = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		exponent1Hex = wiz.framework.wizrsa.main.doPaddingOnHexstring privateKey.dmp1.toString(16)
		exponent1IntBuf = new Buffer(exponent1Hex, 'hex')
		exponent1.setValue(exponent1IntBuf)
		exponent2 = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		exponent2Hex = wiz.framework.wizrsa.main.doPaddingOnHexstring privateKey.dmq1.toString(16)
		exponent2IntBuf = new Buffer(exponent2Hex, 'hex')
		exponent2.setValue(exponent2IntBuf)
		coefficient = s1.branchAdd(new wiz.framework.wizrsa.parser.integer())
		coefficientHex = wiz.framework.wizrsa.main.doPaddingOnHexstring privateKey.coeff.toString(16)
		coefficientIntBuf = new Buffer(coefficientHex, 'hex')
		coefficient.setValue(coefficientIntBuf)
		return key

	toPEMbuffer: () =>
		header = "-----BEGIN RSA PRIVATE KEY-----\n"
		footer = "-----END RSA PRIVATE KEY-----\n"
		publicPEM = rsa.linebrk(@encode().toString('base64'),64) + "\n"
		pemBuffer = new Buffer(header+publicPEM+footer)
		return pemBuffer

	stripHeaderFooter: (stringValue) =>
		stringValue = stringValue.replace("-----BEGIN RSA PRIVATE KEY-----", "")
		stringValue = stringValue.replace("-----END RSA PRIVATE KEY-----", "")
		stringValue = stringValue.replace(/[\s\n]+/g, "")
		return stringValue

class wiz.framework.wizrsa.parser.certificate extends wiz.framework.wizrsa.parser.key
	constructor: () ->
		super()

	stripHeaderFooter: (stringValue) =>
		stringValue = stringValue.replace("-----BEGIN CERTIFICATE-----", "")
		stringValue = stringValue.replace("-----END CERTIFICATE-----", "")
		stringValue = stringValue.replace(/[\s\n]+/g, "")
		return stringValue

class wiz.framework.wizrsa.parser.publicKey extends wiz.framework.wizrsa.parser.key

	@fromModulusExponent: (modulus, publicExponent) =>
		key = new wiz.framework.wizrsa.parser.publicKey(modulus, publicExponent)
		s1 = key.branchAdd(new wiz.framework.wizrsa.parser.sequence())
		s2 = s1.branchAdd(new wiz.framework.wizrsa.parser.sequence())
		oid1 = s2.branchAdd(new wiz.framework.wizrsa.parser.oid())
		oid1.setValue(new Buffer(wiz.framework.wizrsa.main.DER_ALGORITHM_ID, 'hex'))
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
		footer = "-----END PUBLIC KEY-----\n"
		publicPEM = rsa.linebrk(@encode().toString('base64'),64) + "\n"
		pemBuffer = new Buffer(header+publicPEM+footer)
		return pemBuffer

	@stripHeaderFooter: (stringValue) =>
		stringValue = stringValue.replace("-----BEGIN PUBLIC KEY-----", "")
		stringValue = stringValue.replace("-----END PUBLIC KEY-----", "")
		stringValue = stringValue.replace(/[\s\n]+/g, "")
		return stringValue

class wiz.framework.wizrsa.parser.encapsulatingasn extends wiz.framework.wizrsa.parser.asnnode
	encode: () =>
		v = new Buffer(0)
		#x = @each (f) =>
		n = @branchList.tail
		while n
			v = Buffer.concat([v,n.encode()])
			n = n.prev
		@value = v
		super()

#class wiz.framework.wizrsa.parser.parsePublicKey


#fs = require 'fs'
#pubkey = fs.readFileSync 'public.pem'
#blah = wiz.framework.wizrsa.parser.publicKey.fromBuffer(pubkey)
#privkeybuf = fs.readFileSync 'private.pem'
#blah = wiz.framework.wizrsa.parser.privateKey.fromBuffer(privkeybuf)
#privkey = new rsa.Key()
#privkey.generate(2048, "10001")
#console.log privkey.n.toString(16).length
#blah = wiz.framework.wizrsa.parser.privateKey.fromRSAkey(privkey)
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
#console.log blah.toPEMbuffer().toString('utf8')
