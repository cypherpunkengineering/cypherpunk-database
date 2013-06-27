# copyright 2013 wiz technologies inc.

require '..'
require '../util/list'

BigInteger = require './jsbn'
SecureRandom = require './rng'

wiz.package 'wiz.framework.rsa'

class wiz.framework.rsa.asnnode extends wiz.framework.list.tree

	class scope #{{{
		constructor: (@id, @description) ->
	#}}}
	@scopesByBits: #{{{
		0b00000000:	new scope(0b00000000, "UNIVERSAL")
		0b01000000:	new scope(0b01000000, "APPLICATION")
		0b10000000:	new scope(0b10000000, "CONTEXT")
		0b11000000:	new scope(0b11000000, "PRIVATE")
	#}}}
	@scopesByName: #{{{
		UNIVERSAL:		@scopesByBits[0b00000000]
		APPLICATION:	@scopesByBits[0b01000000]
		CONTEXT:		@scopesByBits[0b10000000]
		PRIVATE:		@scopesByBits[0b11000000]
	#}}}

	class node #{{{
		constructor: (@id, @description, @printable = false, @container = false) ->
	#}}}
	@typesByID: #{{{

		0x00: new node(0x00, 'basic encoding rule header')
		0x01: new node(0x01, 'boolean')
		0x02: new node(0x02, 'integer')
		0x03: new node(0x03, 'bit string', false, true)
		0x04: new node(0x04, 'octet string', false, true)
		0x05: new node(0x05, 'null')
		0x06: new node(0x06, 'object identifier', true)
		0x07: new node(0x07, 'ObjectDescriptor')
		0x08: new node(0x08, 'instance of/external')
		0x09: new node(0x09, 'real')
		0x0A: new node(0x0A, 'enumerated')
		0x0B: new node(0x0B, 'pdv')
		0x0C: new node(0x0C, 'utf8string', true)
		0x0D: new node(0x0D, 'relative-oid')
		0x10: new node(0x10, 'sequence', false, true)
		0x11: new node(0x11, 'set, set of', false, true)
		0x12: new node(0x12, 'numeric string', true)
		0x13: new node(0x13, 'printable string', true)
		0x14: new node(0x14, 'teletex string')
		0x15: new node(0x15, 'videotex string')
		0x16: new node(0x16, 'ia5string')
		0x17: new node(0x17, 'utctime', true)
		0x18: new node(0x18, 'GeneralizedTime', true)
		0x19: new node(0x19, 'GraphicString', true)
		0x1A: new node(0x1A, 'VisibleString, ISO64String')
		0x1B: new node(0x1B, 'GeneralString', true)
		0x1C: new node(0x1C, 'UniversalString', true)
		0x1D: new node(0x1D, 'character string', true)
		0x1E: new node(0x1E, 'BMPString', true)
	#}}}
	@typesByName: #{{{

		BER:			@typesByID[0x00]
		BOOL:			@typesByID[0x01]
		INTEGER:		@typesByID[0x02]
		BITSTRING:		@typesByID[0x03]
		OCTET:			@typesByID[0x04]
		NULLOBJ:		@typesByID[0x05]
		OID:			@typesByID[0x06]
		OD:				@typesByID[0x07]
		INSTOF:			@typesByID[0x08]
		REAL:			@typesByID[0x09]
		ENUM:			@typesByID[0x0A]
		EPDV:			@typesByID[0x0B]
		UTF8STRING:		@typesByID[0x0C]
		RELATIVEOLD:	@typesByID[0x0D]
		SEQUENCE:		@typesByID[0x10]
		SETOF:			@typesByID[0x11]
		NUMERIC:		@typesByID[0x12]
		PRINTABLE:		@typesByID[0x13]
		TELETEX:		@typesByID[0x14]
		VIDEOTEX:		@typesByID[0x15]
		IA5:			@typesByID[0x16]
		UTCTIME:		@typesByID[0x17]
		GENTIME:		@typesByID[0x18]
		GRAPHIC:		@typesByID[0x19]
		VISIBLE:		@typesByID[0x1A]
		GENERAL:		@typesByID[0x1B]
		UNIVERSAL:		@typesByID[0x1C]
		CHARACTER:		@typesByID[0x1D]
		BMP:			@typesByID[0x1E]
	#}}}

	constructor: (@scope, @type, @inBuffer) -> #{{{
		if @scope.id == wiz.framework.rsa.asnnode.scopesByName.CONTEXT.id
			@type.container = true
		super()
	#}}}

	@fromType: (type) => #{{{
		return new wiz.framework.rsa.asnnode(wiz.framework.rsa.asnnode.scopesByName.UNIVERSAL, wiz.framework.rsa.asnnode.typesByName[type])
	#}}}
	@fromBuffer: (inBuffer) => #{{{ parses a single asn node from given slice of buffer

		# get id of root node
		idBuffer = wiz.framework.rsa.asnnode.getASNid(inBuffer)
		idInt = idBuffer.readUInt8(0)
		id = idInt & 0b00011111
		scopeInt = idInt & 0b11000000
		scope = @scopesByBits[scopeInt]
		switch scope.description
			when "UNIVERSAL"
				type = @typesByID[id]
			else
				type = new node(id, "[#{id}]")

		if not type?
			wiz.log.err 'invalid asn id value: '+ id
			return null

		n = new wiz.framework.rsa.asnnode(scope, type, inBuffer)
		return n
	#}}}

	setValue: (inValue) => #{{{
		if @type.id is wiz.framework.rsa.asnnode.typesByName.OID.id && @scope.id is wiz.framework.rsa.asnnode.scopesByName.UNIVERSAL.id
			oidString = inValue.toString('utf8')
			oidNodeArray = oidString.split('.')
			oidEncoded = ''
			oidNodeInt = 0
			for oidNode,n in oidNodeArray
				oidNodeInt = parseInt(oidNode)
				if n == 0
					oidEncoded = parseInt(oidNode * 40)
				else if n == 1
					oidEncoded += parseInt(oidNode)
					oidEncoded = oidEncoded.toString(16)
					oidEncoded = wiz.framework.rsa.root.doPaddingOnHexstring(oidEncoded)
				else if oidNodeInt < 128
					hexString = oidNodeInt.toString(16)
					hexString = wiz.framework.rsa.root.doPaddingOnHexstring(hexString)
					oidEncoded = oidEncoded + hexString
				else
					byteArray = []
					i = 0
					while oidNodeInt > 0
						if i == 0
							byteArray[i] = oidNodeInt & 0x7F
						else
							byteArray[i] = (oidNodeInt & 0x7F) | 0x80
						oidNodeInt = oidNodeInt >> 7
						i++

					while i >= 0
						oidNodeEncoded = oidNodeEncoded << 8
						oidNodeEncoded = oidNodeEncoded | byteArray[i]
						i--
					hexString = oidNodeEncoded.toString(16)
					hexString = wiz.framework.rsa.root.doPaddingOnHexstring(hexString)
					oidEncoded = oidEncoded + hexString
			@value = new Buffer(oidEncoded.toString(16), 'hex')
		else
			@value = inValue
	#}}}

	@getASNid: (inBuffer) => #{{{
		idByte = inBuffer.slice(0,1)
		return idByte
	#}}}
	getASNsizeBufferLength: () => #{{{
		# Size buffer length should always be 1 byte
		lengthByte = @inBuffer.slice(1,2).readUInt8(0)
		if lengthByte < 128
			# Return -1 if we don't need to advance position when reading sizebufferlength
			return -1
		sizeBufLength = lengthByte - 0x80
		return sizeBufLength
	#}}}
	getASNvalueSize: () => #{{{
		sizeBufferLength = @getASNsizeBufferLength()
		if sizeBufferLength == -1
			sizeBuf = @inBuffer.slice(1,2)
		else
			sizeBuf = @inBuffer.slice(2, 2+sizeBufferLength)
		size = parseInt(sizeBuf.toString('hex'), 16)
		return size
	#}}}
	getValueBuffer: () => #{{{
		startPtr = 2
		sizeBufSize = @getASNsizeBufferLength()
		valueSize = @getASNvalueSize()

		if sizeBufSize == -1
			value = @inBuffer.slice(startPtr, startPtr + valueSize)
		else
			value = @inBuffer.slice(startPtr + sizeBufSize, startPtr + sizeBufSize + valueSize)

		# strip off trailing bits for bitstring
		if @type.id == wiz.framework.rsa.asnnode.typesByName.BITSTRING.id and value.readUInt8(0) == 0
			# TODO: properly parse trailing bits if != 0
			value = value.slice(1, value.length)

		return value
	#}}}
	getNodeSize: () => #{{{
		size = @getASNsizeBufferLength()
		if size < 0
			size = 1
		else
			size++
		size += @getASNvalueSize() + 1
		return size
	#}}}

	toString: () => #{{{
		value = @getValueBuffer()
		if value?
			if @type.id is wiz.framework.rsa.asnnode.typesByName.OID.id && @scope.id is wiz.framework.rsa.asnnode.scopesByName.UNIVERSAL.id
				firstTwoNodes = value.readUInt8(0)
				firstNode = Math.floor(firstTwoNodes / 40)
				secondNode = firstTwoNodes % 40
				oidString = "#{firstNode}.#{secondNode}"
				oidNode = 0
				for i in [1..value.length-1]
					oidNode = oidNode << 7
					currentByte = value.slice(i,i+1)
					cb = currentByte.readUInt8(0) & 0x7F
					oidNode = oidNode | cb
					if (currentByte.readUInt8(0) < 128)
						oidString += ".#{oidNode}"
						oidNode = 0
				return oidString
			else
				return value.toString('utf8')
	#}}}
	generateTag: () => #{{{
		combined = (@scope.id | @type.id)

		if @type.id == wiz.framework.rsa.asnnode.typesByName.SEQUENCE.id
			combined = (combined | 0b00100000)

		tag = wiz.framework.rsa.root.doPaddingOnHexstring(combined.toString(16))

		return new Buffer(tag, 'hex')
	#}}}
	encodeASN: () => #{{{
		@encodeContainer() if @type.container
		result = @generateTag()
		valueBuffer = (if @value? then @value else @getValueBuffer())

		if @type.id == wiz.framework.rsa.asnnode.typesByName.BITSTRING.id
			valueBuffer = Buffer.concat([new Buffer('00', 'hex'), valueBuffer])

		size = 0
		size = valueBuffer.length if valueBuffer

		# Calculate how many bytes are needed to store the value of size
		if size < 127
			sizehex = new Buffer("0" + size.toString(16), 'hex')
			result = Buffer.concat([result, sizehex])
		else
			hexstring = size.toString(16)

			# pads the hexstring to always have even number of bytes
			hexstring = "0" + hexstring if hexstring.length % 2 is 1

			# create new buffer
			sizeBuf = new Buffer(hexstring, 'hex')
			# 0x80 + (2 or 3)
			firstByte = 0x80 + sizeBuf.length
			fb = new Buffer(firstByte.toString(16), 'hex')
			result = Buffer.concat([result, fb, sizeBuf])

		result = Buffer.concat([result, valueBuffer])
		return result
	#}}}
	encodeContainer: () => #{{{
		v = new Buffer(0)
		#x = @each (f) =>
		n = @branchList.tail
		while n
			v = Buffer.concat([v,n.encodeASN()])
			n = n.prev
		@value = v
	#}}}

class wiz.framework.rsa.root extends wiz.framework.list.tree

	#{{{
	@PRIVATE_KEY_HEADER = "-----BEGIN RSA PRIVATE KEY-----"
	@PRIVATE_KEY_FOOTER = "-----END RSA PRIVATE KEY-----"

	@PUBLIC_KEY_HEADER = "-----BEGIN PUBLIC KEY-----"
	@PUBLIC_KEY_FOOTER = "-----END PUBLIC KEY-----"

	@X509_HEADER = "-----BEGIN CERTIFICATE-----"
	@X509_FOOTER = "-----END CERTIFICATE-----"
	#}}}

	@fromBuffer: (inBuffer) => #{{{ determine which type of object to create and create it
		stringValue = inBuffer.toString("utf8")
		headerLength = stringValue.indexOf('\n')
		header = stringValue.substr(0, headerLength)
		switch header
			when @PRIVATE_KEY_HEADER
				rootNode = new wiz.framework.rsa.privateKey()
			when @PUBLIC_KEY_HEADER
				rootNode = new wiz.framework.rsa.publicKey()
			when @X509_HEADER
				rootNode = new wiz.framework.rsa.certificate()
			else
				return null

		strippedString = rootNode.stripHeaderFooter(stringValue)
		outBuffer = new Buffer(strippedString, 'base64')
		rootBranch = @parseBuffer(outBuffer, rootNode)
		rootBranch.setValuesFromTree()
		return rootBranch
	#}}}
	@parseBuffer: (inBuffer, currentBranch, position = 0) => #{{{ recursive method to parse containers
		while (position < inBuffer.length)
			slice = inBuffer.slice(position)
			newBranch = currentBranch.branchAdd(wiz.framework.rsa.asnnode.fromBuffer(slice))
			#wiz.log.debug "decription is #{newBranch.type.description}"
			if newBranch.type.container
				@parseBuffer(newBranch.getValueBuffer(), newBranch, 0)
			position += newBranch.getNodeSize()
		return currentBranch
	#}}}

	@doPaddingOnHexstring: (hexstring) => #{{{
		if hexstring.length % 2 == 1
			hexstring = "0" + hexstring
		return hexstring
	#}}}

	printTree: () => #{{{
		@tailEach 0, (d, n) =>
			indent = ''
			for i in [0..d]
				continue if i is 0
				indent += '|  '
			str = indent
			str += n.type.description + ' '
			str += n.toString() if n.type.printable or n.scope.id isnt wiz.framework.rsa.asnnode.scopesByName.UNIVERSAL.id
			console.log str
	#}}}
	@linebrk: (buf, n) -> #{{{
		s = buf.toString("ascii")
		ret = ""
		i = 0
		while i + n < s.length
			ret += s.substring(i, i + n) + "\n"
			i += n
		ret + s.substring(i, s.length)
	#}}}
	encodeASN: () => #{{{
		v = new Buffer(0)
		n = @branchList.tail
		while n
			v = Buffer.concat([v,n.encodeASN()])
			n = n.prev
		return v
	#}}}

class wiz.framework.rsa.key extends wiz.framework.rsa.root

	list: [ #{{{
	]#}}}
	constructor: (@modulus, @publicExponent) -> #{{{
		super()
	#}}}

	@generateKeypair: (B = 2048, E = "10001") => #{{{ bits is base 10, publicExponent is base 16
		key =
			n: null
			e: 0
			d: null
			p: null
			q: null
			dmp1: null
			dmq1: null
			coeff: null

		rng = new SecureRandom()
		qs = B >> 1
		key.e = parseInt(E, 16)
		ee = new BigInteger(E, 16)
		loop
			loop
				key.p = new BigInteger(B - qs, 1, rng)
				break if key.p.subtract(BigInteger.ONE).gcd(ee).compareTo(BigInteger.ONE) is 0 and key.p.isProbablePrime(10)
			loop
				key.q = new BigInteger(qs, 1, rng)
				break if key.q.subtract(BigInteger.ONE).gcd(ee).compareTo(BigInteger.ONE) is 0 and key.q.isProbablePrime(10)
			if key.p.compareTo(key.q) <= 0
				t = key.p
				key.p = key.q
				key.q = t
			p1 = key.p.subtract(BigInteger.ONE)
			q1 = key.q.subtract(BigInteger.ONE)
			phi = p1.multiply(q1)
			if phi.gcd(ee).compareTo(BigInteger.ONE) is 0
				key.n = key.p.multiply(key.q)
				key.d = ee.modInverse(phi)

				# if modulus bitlength is not what was requested, start generate over
				continue unless key.n.bitLength() is B
				key.dmp1 = key.d.mod(p1)
				key.dmq1 = key.d.mod(q1)
				key.coeff = key.q.modInverse(key.p)
				break

		keypair =
			private: new wiz.framework.rsa.privateKey.fromRSAkey(key)
			public: new wiz.framework.rsa.publicKey.fromRSAkey(key)

		return keypair
	#}}}

	encrypt: (text) => #{{{ Return the PKCS#1 RSA encryption of "text" as an even-length hex string
		m = @pkcs1pad2(text, (@modulus.bitLength() + 7) >> 3)
		return null if m is null

		c = @doPublic(m)
		return null if c is null

		h = c.toString(16)

		if (h.length & 1) == 0
			return h
		else
			return "0" + h
	#}}}
	decrypt: (ctext) => #{{{
		c = new BigInteger(ctext, 16)
		m = @doPrivate(c)
		return null if m is null
		return @pkcs1unpad2(m, (@modulus.bitLength() + 7) >> 3)
	#}}}

	doPublic: (x) => #{{{ Perform raw public operation on "x": return x^e (mod n)
		x.modPowInt(@publicExponent, @modulus)
	#}}}
	doPrivate: (x) => #{{{ Perform raw private operation on "x": return x^d (mod n)
		if (@prime1 == null || @prime2 == null)
			return x.modPow(@d, @modulus)

		# TODO: re-calculate any missing CRT params
		xp = x.mod(@prime1).modPow(@exponent1, @prime1)
		xq = x.mod(@prime2).modPow(@exponent2, @prime2)

		while (xp.compareTo(xq) < 0)
			xp = xp.add(@prime1)
		return xp.subtract(xq).multiply(@coefficient).mod(@prime1).multiply(@prime2).add(xq)
	#}}}

	pkcs1pad2: (s, n) => #{{{ PKCS#1 (type 2, random) pad input string s to n bytes, and return a bigint
		# TODO: fix for utf-8
		if n < s.length + 11
			wiz.log.err("Message too long for RSA (n=" + n + ", l=" + s.length + ")")
			return null

		ba = new Array()
		i = s.length - 1

		while i >= 0 and n > 0
			c = s.charCodeAt(i--)
			if c < 128 # encode using utf-8
				ba[--n] = c
			else if (c > 127) and (c < 2048)
				ba[--n] = (c & 63) | 128
				ba[--n] = (c >> 6) | 192
			else
				ba[--n] = (c & 63) | 128
				ba[--n] = ((c >> 6) & 63) | 128
				ba[--n] = (c >> 12) | 224
		ba[--n] = 0

		rng = new SecureRandom()
		x = new Array()
		while n > 2 # random non-zero pad
			x[0] = 0
			rng.nextBytes x	while x[0] is 0
			ba[--n] = x[0]
		ba[--n] = 2
		ba[--n] = 0

		return new BigInteger(ba)
	#}}}
	pkcs1unpad2: (d, n) => #{{{ # Undo PKCS#1 (type 2, random) padding and, if valid, return the plaintext
		b = d.toByteArray()
		i = 0

		while i < b.length and b[i] is 0
			++i

		if b.length - i isnt n - 1 or b[i] isnt 2
			return null

		++i

		until b[i] is 0
			if ++i >= b.length
				return null

		ret = []
		while ++i < b.length
			c = b[i] & 255
			ret.push c

		#This will need to be tested more, but Node doesn't like all of this!
		#if (c < 128) { // utf-8 decode
		#ret += String.fromCharCode(c)
		#} else if ((c > 191) && (c < 224)) {
		#	ret += String.fromCharCode(((c & 31) << 6) | (b[i + 1] & 63))
		#	++i
		#} else {
		#	ret += String.fromCharCode(((c & 15) << 12)
		#			| ((b[i + 1] & 63) << 6) | (b[i + 2] & 63))
		#	i += 2
		#}
		return new Buffer(ret)
	#}}}

	getModulus: () => #{{{
		return @modulus
	#}}}
	getPublicExponent: () => #{{{
		return @publicExponent
	#}}}

	setValue: (x, b) => #{{{ set value of given index
		label = @list[x]
		if b.length > 4 # use a BigInteger if necessary
			v = new BigInteger(b.toString('hex'), 16)
		else
			v = parseInt(b.toString('hex'), 16)

		#console.log "setting @#{label} to #{v}"
		this[label] = v
	#}}}

class wiz.framework.rsa.privateKey extends wiz.framework.rsa.key

	list: [ #{{{
		'version'
		'modulus'			# old @n
		'publicExponent'	# old @e
		'privateExponent'	# old @d
		'prime1'			# old @p
		'prime2'			# old @q
		'exponent1'			# old @dmp1
		'exponent2'			# old @dmq1
		'coefficient'		# old @coeff
	] #}}}
	constructor: (@modulus, @publicExponent, @privateExponent, @prime1, @prime2, @exponent1, @exponent2, @coefficient) -> #{{{ private constructor
		super()
	#}}}

	@fromRSAkey: (privateKey) => #{{{ public constructor
		key = new wiz.framework.rsa.privateKey()
		s1 = key.branchAdd(wiz.framework.rsa.asnnode.fromType('SEQUENCE'))
		version = s1.branchAdd(wiz.framework.rsa.asnnode.fromType('INTEGER'))
		version.setValue(new Buffer("00",'hex'))
		modulus = s1.branchAdd(wiz.framework.rsa.asnnode.fromType('INTEGER'))
		modulusHex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.n.toString(16)
		modulusIntBuf = new Buffer(modulusHex, 'hex')
		modulus.setValue(modulusIntBuf)
		publicExponent = s1.branchAdd(wiz.framework.rsa.asnnode.fromType('INTEGER'))
		publicExponentHex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.e.toString(16)
		publicExponentIntBuf = new Buffer(publicExponentHex, 'hex')
		publicExponent.setValue(publicExponentIntBuf)
		privateExponent = s1.branchAdd(wiz.framework.rsa.asnnode.fromType('INTEGER'))
		privateExponentHex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.d.toString(16)
		privateExponentIntBuf = new Buffer(privateExponentHex, 'hex')
		privateExponent.setValue(privateExponentIntBuf)
		prime1 = s1.branchAdd(wiz.framework.rsa.asnnode.fromType('INTEGER'))
		prime1Hex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.p.toString(16)
		prime1IntBuf = new Buffer(prime1Hex, 'hex')
		prime1.setValue(prime1IntBuf)
		prime2 = s1.branchAdd(wiz.framework.rsa.asnnode.fromType('INTEGER'))
		prime2Hex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.q.toString(16)
		prime2IntBuf = new Buffer(prime2Hex, 'hex')
		prime2.setValue(prime2IntBuf)
		exponent1 = s1.branchAdd(wiz.framework.rsa.asnnode.fromType('INTEGER'))
		exponent1Hex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.dmp1.toString(16)
		exponent1IntBuf = new Buffer(exponent1Hex, 'hex')
		exponent1.setValue(exponent1IntBuf)
		exponent2 = s1.branchAdd(wiz.framework.rsa.asnnode.fromType('INTEGER'))
		exponent2Hex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.dmq1.toString(16)
		exponent2IntBuf = new Buffer(exponent2Hex, 'hex')
		exponent2.setValue(exponent2IntBuf)
		coefficient = s1.branchAdd(wiz.framework.rsa.asnnode.fromType('INTEGER'))
		coefficientHex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.coeff.toString(16)
		coefficientIntBuf = new Buffer(coefficientHex, 'hex')
		coefficient.setValue(coefficientIntBuf)
		return key
	#}}}
	@fromPEMbuffer: (privatePEM) => #{{{ public constructor
		parserPrivateKey = wiz.framework.rsa.fromBuffer(privatePEM)
		privateKey = new wiz.framework.rsa.key()
		privateKey.setPrivateEx(parserPrivateKey.modulus.toString('hex'),
								parserPrivateKey.publicExponent.toString('hex'),
								parserPrivateKey.privateExponent.toString('hex'),
								parserPrivateKey.prime1.toString('hex'),
								parserPrivateKey.prime2.toString('hex'),
								parserPrivateKey.exponent1.toString('hex'),
								parserPrivateKey.exponent2.toString('hex'),
								parserPrivateKey.coefficient.toString('hex'))
		return privateKey
	#}}}

	setValuesFromTree: () => #{{{
		n = @branchList.tail
		i = 0
		@tailEach 0, (d, n) =>
			if n.type.container is false
				#console.log n.type
				@setValue(i, n.getValueBuffer())
				i++
	#}}}

	toPEMbuffer: () => #{{{
		header = "-----BEGIN RSA PRIVATE KEY-----\n"
		footer = "-----END RSA PRIVATE KEY-----\n"
		privatePEM = wiz.framework.rsa.root.linebrk(@encodeASN().toString('base64'),64) + "\n"
		pemBuffer = new Buffer(header+privatePEM+footer)
		return pemBuffer
	#}}}

	stripHeaderFooter: (stringValue) => #{{{
		stringValue = stringValue.replace("-----BEGIN RSA PRIVATE KEY-----", "")
		stringValue = stringValue.replace("-----END RSA PRIVATE KEY-----", "")
		stringValue = stringValue.replace(/[\s\n]+/g, "")
		return stringValue
	#}}}

class wiz.framework.rsa.publicKey extends wiz.framework.rsa.key
	#@RSA_ALGORITHM_OID = '1.2.2888.113549.1.5.1'
	@RSA_ALGORITHM_OID: '1.2.840.113549.1.1.1'

	treeStructure: [ #{{{
		wiz.framework.rsa.asnnode.typesByName.SEQUENCE.id
		wiz.framework.rsa.asnnode.typesByName.SEQUENCE.id
		wiz.framework.rsa.asnnode.typesByName.OID.id
		wiz.framework.rsa.asnnode.typesByName.NULLOBJ.id
		wiz.framework.rsa.asnnode.typesByName.BITSTRING.id
		wiz.framework.rsa.asnnode.typesByName.SEQUENCE.id
		wiz.framework.rsa.asnnode.typesByName.INTEGER.id
		wiz.framework.rsa.asnnode.typesByName.INTEGER.id
	] #}}}
	list: [ #{{{
		'modulus'
		'publicExponent'
	] #}}}

	@fromPrivateKey: (privateKey) => #{{{
		key = new wiz.framework.rsa.publicKey(modulus, publicExponent)
		s1 = key.branchAdd(wiz.framework.rsa.asnnode.fromType('SEQUENCE'))
		s2 = s1.branchAdd(wiz.framework.rsa.asnnode.fromType('SEQUENCE'))
		oid1 = s2.branchAdd(wiz.framework.rsa.asnnode.fromType('OID'))
		oid1.setValue(new Buffer(wiz.framework.rsa.publicKey.RSA_ALGORITHM_OID, 'utf8'))
		null1 = s2.branchAdd(wiz.framework.rsa.asnnode.fromType('NULLOBJ'))
		null1.setValue(new Buffer(0))
		bs1 = s1.branchAdd(wiz.framework.rsa.asnnode.fromType('BITSTRING'))
		s3 = bs1.branchAdd(wiz.framework.rsa.asnnode.fromType('SEQUENCE'))
		modulus = s3.branchAdd(new wiz.framework.rsa.asnnode.fromType('INTEGER'))
		modulus.setValue(privateKey.modulus)
		publicExponent = s3.branchAdd(new wiz.framework.rsa.asnnode.fromType('INTEGER'))
		publicExponent.setValue(privateKey.publicExponent)
		return key
	#}}}
	@fromRSAkey: (publicKey) => #{{{
		key = new wiz.framework.rsa.publicKey()
		s1 = key.branchAdd(wiz.framework.rsa.asnnode.fromType('SEQUENCE'))
		s2 = s1.branchAdd(wiz.framework.rsa.asnnode.fromType('SEQUENCE'))
		oid1 = s2.branchAdd(wiz.framework.rsa.asnnode.fromType('OID'))
		oid1.setValue(new Buffer(wiz.framework.rsa.publicKey.RSA_ALGORITHM_OID, 'utf8'))
		null1 = s2.branchAdd(wiz.framework.rsa.asnnode.fromType('NULLOBJ'))
		null1.setValue(new Buffer("00",'hex'))
		bs1 = s1.branchAdd(wiz.framework.rsa.asnnode.fromType('BITSTRING'))
		s3 = bs1.branchAdd(wiz.framework.rsa.asnnode.fromType('SEQUENCE'))
		modulus = s3.branchAdd(wiz.framework.rsa.asnnode.fromType('INTEGER'))
		modulusHex = wiz.framework.rsa.key.doPaddingOnHexstring publicKey.n.toString(16)
		modulusIntBuf = new Buffer(modulusHex,'hex')
		modulus.setValue(modulusIntBuf)
		publicExponent = s3.branchAdd(wiz.framework.rsa.asnnode.fromType('INTEGER'))
		publicExponentHex = wiz.framework.rsa.key.doPaddingOnHexstring publicKey.e.toString(16)
		publicExponentIntBuf = new Buffer(publicExponentHex,'hex')
		publicExponent.setValue(publicExponentIntBuf)
		return key
	#}}}
	@fromPEMbuffer: (publicPEM) => #{{{
		parserPublicKey = wiz.framework.rsa.fromBuffer(publicPEM)
		publicKey = new wiz.framework.rsa.key()
		publicKey.setPublic(parserPublicKey.modulus.toString('hex'),
							parserPublicKey.publicExponent.toString('hex'))
		return publicKey
	#}}}

	setValuesFromTree: () => #{{{
		n = @branchList.tail
		i = 0
		x = 0
		@tailEach 0, (d, n) =>
			if @treeStructure[i] isnt n.type.id
				wiz.log.err "Not a valid RSA public key"
				return null
			if n.type.id is wiz.framework.rsa.asnnode.typesByName.OID.id && n.toString() != wiz.framework.rsa.publicKey.RSA_ALGORITHM_OID
				wiz.log.err "Could not find RSA algorithm ID"
				return null
			else if n.type.id is wiz.framework.rsa.asnnode.typesByName.INTEGER.id
				@setValue(x, n.getValueBuffer())
				x++
			i++
	#}}}

	toPEMbuffer: () => #{{{
		header = "-----BEGIN PUBLIC KEY-----\n"
		footer = "-----END PUBLIC KEY-----\n"
		publicPEM = wiz.framework.rsa.root.linebrk(@encodeASN().toString('base64'),64) + "\n"
		pemBuffer = new Buffer(header+publicPEM+footer)
		return pemBuffer
	#}}}

	stripHeaderFooter: (stringValue) => #{{{
		stringValue = stringValue.replace("-----BEGIN PUBLIC KEY-----", "")
		stringValue = stringValue.replace("-----END PUBLIC KEY-----", "")
		stringValue = stringValue.replace(/[\s\n]+/g, "")
		return stringValue
	#}}}

class wiz.framework.rsa.certificate extends wiz.framework.rsa.root

	constructor: () -> #{{{
		super()
	#}}}

	stripHeaderFooter: (stringValue) => #{{{
		stringValue = stringValue.replace("-----BEGIN CERTIFICATE-----", "")
		stringValue = stringValue.replace("-----END CERTIFICATE-----", "")
		stringValue = stringValue.replace(/[\s\n]+/g, "")
		return stringValue
	#}}}

# vim: foldmethod=marker wrap

