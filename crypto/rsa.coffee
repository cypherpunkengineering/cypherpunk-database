# copyright 2013 wiz technologies inc.

require '..'
require './asn'

BigInteger = require './jsbn'
SecureRandom = require './rng'

wiz.package 'wiz.framework.rsa'

class wiz.framework.rsa.key extends wiz.framework.asn.root

	constructor: () -> #{{{
		super()
		@list ?= []
		@version = null
		@modulus = null
		@publicExponent = null
		@privateExponent = null
		@prime1 = null
		@prime2 = null
		@exponent1 = null
		@exponent2 = null
		@coefficient = null
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
	decrypt: (ctext) => #{{{ Return the PKCS#1 RSA decryption of an even-length hex string as a plain string
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
	@title: 'RSA PRIVATE KEY'

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
		s1 = key.branchAdd(wiz.framework.asn.node.fromType('SEQUENCE'))
		version = s1.branchAdd(wiz.framework.asn.node.fromType('INTEGER'))
		version.setValue(new Buffer("00",'hex'))
		modulus = s1.branchAdd(wiz.framework.asn.node.fromType('INTEGER'))
		modulusHex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.n.toString(16)
		modulusIntBuf = new Buffer(modulusHex, 'hex')
		modulus.setValue(modulusIntBuf)
		publicExponent = s1.branchAdd(wiz.framework.asn.node.fromType('INTEGER'))
		publicExponentHex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.e.toString(16)
		publicExponentIntBuf = new Buffer(publicExponentHex, 'hex')
		publicExponent.setValue(publicExponentIntBuf)
		privateExponent = s1.branchAdd(wiz.framework.asn.node.fromType('INTEGER'))
		privateExponentHex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.d.toString(16)
		privateExponentIntBuf = new Buffer(privateExponentHex, 'hex')
		privateExponent.setValue(privateExponentIntBuf)
		prime1 = s1.branchAdd(wiz.framework.asn.node.fromType('INTEGER'))
		prime1Hex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.p.toString(16)
		prime1IntBuf = new Buffer(prime1Hex, 'hex')
		prime1.setValue(prime1IntBuf)
		prime2 = s1.branchAdd(wiz.framework.asn.node.fromType('INTEGER'))
		prime2Hex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.q.toString(16)
		prime2IntBuf = new Buffer(prime2Hex, 'hex')
		prime2.setValue(prime2IntBuf)
		exponent1 = s1.branchAdd(wiz.framework.asn.node.fromType('INTEGER'))
		exponent1Hex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.dmp1.toString(16)
		exponent1IntBuf = new Buffer(exponent1Hex, 'hex')
		exponent1.setValue(exponent1IntBuf)
		exponent2 = s1.branchAdd(wiz.framework.asn.node.fromType('INTEGER'))
		exponent2Hex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.dmq1.toString(16)
		exponent2IntBuf = new Buffer(exponent2Hex, 'hex')
		exponent2.setValue(exponent2IntBuf)
		coefficient = s1.branchAdd(wiz.framework.asn.node.fromType('INTEGER'))
		coefficientHex = wiz.framework.rsa.key.doPaddingOnHexstring privateKey.coeff.toString(16)
		coefficientIntBuf = new Buffer(coefficientHex, 'hex')
		coefficient.setValue(coefficientIntBuf)
		return key
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
		privatePEM = wiz.framework.asn.root.linebrk(@encodeASN().toString('base64'),64) + "\n"
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
	@title: 'RSA PUBLIC KEY'
	#@RSA_ALGORITHM_OID = '1.2.2888.113549.1.5.1'
	@RSA_ALGORITHM_OID: '1.2.840.113549.1.1.1'

	treeStructure: [ #{{{
		wiz.framework.asn.node.typesByName.SEQUENCE.id
		wiz.framework.asn.node.typesByName.SEQUENCE.id
		wiz.framework.asn.node.typesByName.OID.id
		wiz.framework.asn.node.typesByName.NULLOBJ.id
		wiz.framework.asn.node.typesByName.BITSTRING.id
		wiz.framework.asn.node.typesByName.SEQUENCE.id
		wiz.framework.asn.node.typesByName.INTEGER.id
		wiz.framework.asn.node.typesByName.INTEGER.id
	] #}}}
	list: [ #{{{
		'modulus'
		'publicExponent'
	] #}}}

	@fromPrivateKey: (privateKey) => #{{{
		key = new wiz.framework.rsa.publicKey(modulus, publicExponent)
		s1 = key.branchAdd(wiz.framework.asn.node.fromType('SEQUENCE'))
		s2 = s1.branchAdd(wiz.framework.asn.node.fromType('SEQUENCE'))
		oid1 = s2.branchAdd(wiz.framework.asn.node.fromType('OID'))
		oid1.setValue(new Buffer(wiz.framework.rsa.publicKey.RSA_ALGORITHM_OID, 'utf8'))
		null1 = s2.branchAdd(wiz.framework.asn.node.fromType('NULLOBJ'))
		null1.setValue(null)
		bs1 = s1.branchAdd(wiz.framework.asn.node.fromType('BITSTRING'))
		s3 = bs1.branchAdd(wiz.framework.asn.node.fromType('SEQUENCE'))
		modulus = s3.branchAdd(new wiz.framework.asn.node.fromType('INTEGER'))
		modulus.setValue(privateKey.modulus)
		publicExponent = s3.branchAdd(new wiz.framework.asn.node.fromType('INTEGER'))
		publicExponent.setValue(privateKey.publicExponent)
		return key
	#}}}
	@fromRSAkey: (publicKey) => #{{{
		key = new wiz.framework.rsa.publicKey()
		s1 = key.branchAdd(wiz.framework.asn.node.fromType('SEQUENCE'))
		s2 = s1.branchAdd(wiz.framework.asn.node.fromType('SEQUENCE'))
		oid1 = s2.branchAdd(wiz.framework.asn.node.fromType('OID'))
		oid1.setValue(new Buffer(wiz.framework.rsa.publicKey.RSA_ALGORITHM_OID, 'utf8'))
		null1 = s2.branchAdd(wiz.framework.asn.node.fromType('NULLOBJ'))
		null1.setValue(new Buffer("00",'hex'))
		bs1 = s1.branchAdd(wiz.framework.asn.node.fromType('BITSTRING'))
		s3 = bs1.branchAdd(wiz.framework.asn.node.fromType('SEQUENCE'))
		modulus = s3.branchAdd(wiz.framework.asn.node.fromType('INTEGER'))
		modulusHex = wiz.framework.rsa.key.doPaddingOnHexstring publicKey.n.toString(16)
		modulusIntBuf = new Buffer(modulusHex,'hex')
		modulus.setValue(modulusIntBuf)
		publicExponent = s3.branchAdd(wiz.framework.asn.node.fromType('INTEGER'))
		publicExponentHex = wiz.framework.rsa.key.doPaddingOnHexstring publicKey.e.toString(16)
		publicExponentIntBuf = new Buffer(publicExponentHex,'hex')
		publicExponent.setValue(publicExponentIntBuf)
		return key
	#}}}

	setValuesFromTree: () => #{{{
		n = @branchList.tail
		i = 0
		x = 0
		@tailEach 0, (d, n) =>
			if @treeStructure[i] isnt n.type.id
				wiz.log.err "Not a valid RSA public key"
				return null
			if n.type.id is wiz.framework.asn.node.typesByName.OID.id && n.toString() != wiz.framework.rsa.publicKey.RSA_ALGORITHM_OID
				wiz.log.err "Could not find RSA algorithm ID"
				return null
			else if n.type.id is wiz.framework.asn.node.typesByName.INTEGER.id
				@setValue(x, n.getValueBuffer())
				x++
			i++
	#}}}

	toPEMbuffer: () => #{{{
		header = "-----BEGIN PUBLIC KEY-----\n"
		footer = "-----END PUBLIC KEY-----\n"
		publicPEM = wiz.framework.asn.root.linebrk(@encodeASN().toString('base64'),64) + "\n"
		pemBuffer = new Buffer(header+publicPEM+footer)
		return pemBuffer
	#}}}

	stripHeaderFooter: (stringValue) => #{{{
		stringValue = stringValue.replace("-----BEGIN PUBLIC KEY-----", "")
		stringValue = stringValue.replace("-----END PUBLIC KEY-----", "")
		stringValue = stringValue.replace(/[\s\n]+/g, "")
		return stringValue
	#}}}

# vim: foldmethod=marker wrap
