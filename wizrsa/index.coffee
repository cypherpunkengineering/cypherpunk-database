# copyright 2013 wiz technologies inc.

require '..'
require './parser'

rsa = require './rsa'

wiz.package 'wiz.framework.wizrsa.main'

class wiz.framework.wizrsa.main
	@TAG_INTEGER = new Buffer('02', 'hex')
	@TAG_BITSTRING = new Buffer('03','hex')
	@TAG_OID = new Buffer('06','hex')
	@TAG_SEQUENCE = new Buffer('30','hex')
	@TAG_NULL = new Buffer('05','hex')

	@DER_ALGORITHM_ID = '2a864886f70d010101'

	@ASNinteger: () =>
		return new wiz.framework.wizrsa.asnvalue(wiz.framework.wizrsa.main.TAG_INTEGER)

	@ASNsequence: () =>
		return new wiz.framework.wizrsa.asnvalue(wiz.framework.wizrsa.main.TAG_SEQUENCE)

	@ASNoid: () =>
		return new wiz.framework.wizrsa.asnvalue(wiz.framework.wizrsa.main.TAG_OID)

	@ASNbitString: () =>
		return new wiz.framework.wizrsa.asnvalue(wiz.framework.wizrsa.main.TAG_BITSTRING)

	@DERalgID: () =>
		return new Buffer(wiz.framework.wizrsa.main.DER_ALGORITHM_ID, 'hex')

	@Version: () =>
		version = new wiz.framework.wizrsa.ASNinteger()
		pbuf = new Buffer("00", 'hex')
		version.setIntBuffer(pbuf)
		return version

	@doPaddingOnHexstring: (hexstring) =>
		if hexstring.length % 2 == 1
			hexstring = "0" + hexstring
		return hexstring

	@loadPrivateKeyFromPEMbuffer: (privatePEM) =>
		parserPrivateKey = wiz.framework.wizrsa.parser.fromBuffer(privatePEM)
		privateKey = new rsa.Key()
		privateKey.setPrivateEx(parserPrivateKey.modulus.toString('hex'),
								parserPrivateKey.publicExponent.toString('hex'),
								parserPrivateKey.privateExponent.toString('hex'),
								parserPrivateKey.prime1.toString('hex'),
								parserPrivateKey.prime2.toString('hex'),
								parserPrivateKey.exponent1.toString('hex'),
								parserPrivateKey.exponent2.toString('hex'),
								parserPrivateKey.coefficient.toString('hex'))
		#privateKey.readPrivateKeyFromPEMString(privatePEM)
		return privateKey

	@loadPublicKeyFromPEMbuffer: (publicPEM) =>
		parserPublicKey = wiz.framework.wizrsa.parser.fromBuffer(publicPEM)
		publicKey = new rsa.Key()
		publicKey.setPublic(parserPublicKey.modulus.toString('hex'),
							parserPublicKey.publicExponent.toString('hex'))
		#publicKey.readPublicKeyFromPEMString(publicPEM)
		return publicKey

	# bits is base 10
	# publicExponent is base 16
	@generateKeyPair: (bits = 2048, publicExponent = "10001") =>
		keypair = new rsa.Key()
		keypair.generate(bits, publicExponent)
		return keypair

	@getModulusAsBufferFromKey: (key) =>
		# Convert BigInteger to binary data
		modulus = wiz.framework.wizrsa.main.doPaddingOnHexstring key.n.toString(16)
		modulusIntBuf = new Buffer(modulus, 'hex')
		return modulusIntBuf

	@getModulusAsASNValueFromKey: (key) =>
		# extract modulus (n) from private key
		modulus = new wiz.framework.wizrsa.main.ASNinteger()
		modulus.setIntBuffer(wiz.framework.wizrsa.getModulusAsBufferFromKey(key))
		console.log 'modulus is:'
		console.log modulus.value
		return modulus

	@getPublicExponentAsBufferFromKey: (key) =>
		# extract public exponent (e) from private key
		publicExponentHexString = wiz.framework.wizrsa.main.doPaddingOnHexstring(key.e.toString(16))
		publicExponentIntBuf = new Buffer(publicExponentHexString, 'hex')
		return publicExponentIntBuf

	@getPublicExponentAsASNValueFromKey: (key) =>
		publicExponent = new wiz.framework.wizrsa.main.ASNinteger()
		publicExponentIntBuf = wiz.framework.wizrsa.main.getPublicExponentAsBufferFromKey(key)
		publicExponent.setIntBuffer(publicExponentIntBuf)
		return publicExponent

	@getPrivateExponentAsBufferFromKey: (key) =>
		# extract private exponent (e) from private key
		privateExponentHexString = wiz.framework.wizrsa.main.doPaddingOnHexstring(key.d.toString(16))
		privateExponentIntBuf = new Buffer(privateExponentHexString, 'hex')
		return privateExponentIntBuf

	@getPrivateExponentAsASNValueFromKey: (key) =>
		privateExponent = new wiz.framework.wizrsa.ASNinteger()
		privateExponentIntBuf = wiz.framework.wizrsa.main.getPrivateExponentAsBufferFromKey(key)
		privateExponent.setIntBuffer(privateExponentIntBuf)
		return privateExponent

	@getPrime1AsBufferFromKey: (key) =>
		# extract prime1 exponent (e) from prime1 key
		prime1HexString = wiz.framework.wizrsa.main.doPaddingOnHexstring(key.p.toString(16))
		prime1IntBuf = new Buffer(prime1HexString, 'hex')
		return prime1IntBuf

	@getPrime1AsASNValueFromKey: (key) =>
		prime1 = new wiz.framework.wizrsa.main.ASNinteger()
		prime1IntBuf = wiz.framework.wizrsa.main.getPrime1AsBufferFromKey(key)
		prime1.setIntBuffer(prime1IntBuf)
		return prime1

	@getPrime2AsBufferFromKey: (key) =>
		# extract prime2 exponent (e) from prime2 key
		prime2HexString = wiz.framework.wizrsa.main.doPaddingOnHexstring(key.q.toString(16))
		prime2IntBuf = new Buffer(prime2HexString, 'hex')
		return prime2IntBuf

	@getPrime2AsASNValueFromKey: (key) =>
		prime2 = new wiz.framework.wizrsa.main.ASNinteger()
		prime2IntBuf = wiz.framework.wizrsa.main.getPrime2AsBufferFromKey(key)
		prime2.setIntBuffer(prime2IntBuf)
		return prime2

	@getExponent1AsBufferFromKey: (key) =>
		# extract exponent1 exponent (e) from exponent1 key
		exponent1HexString = wiz.framework.wizrsa.main.doPaddingOnHexstring(key.dmp1.toString(16))
		exponent1IntBuf = new Buffer(exponent1HexString, 'hex')
		return exponent1IntBuf

	@getExponent1AsASNValueFromKey: (key) =>
		exponent1 = new wiz.framework.wizrsa.main.ASNinteger()
		exponent1IntBuf = wiz.framework.wizrsa.main.getExponent1AsBufferFromKey(key)
		exponent1.setIntBuffer(exponent1IntBuf)
		return exponent1

	@getExponent2AsBufferFromKey: (key) =>
		# extract exponent2 exponent (e) from exponent2 key
		exponent2HexString = wiz.framework.wizrsa.main.doPaddingOnHexstring(key.dmq1.toString(16))
		exponent2IntBuf = new Buffer(exponent2HexString, 'hex')
		return exponent2IntBuf

	@getExponent2AsASNValueFromKey: (key) =>
		exponent2 = new wiz.framework.wizrsa.main.ASNinteger()
		exponent2IntBuf = wiz.framework.wizrsa.main.getExponent2AsBufferFromKey(key)
		exponent2.setIntBuffer(exponent2IntBuf)
		return exponent2

	@getCoeffAsBufferFromKey: (key) =>
		# extract coeff exponent (e) from coeff key
		coeffHexString = wiz.framework.wizrsa.main.doPaddingOnHexstring(key.coeff.toString(16))
		coeffIntBuf = new Buffer(coeffHexString, 'hex')
		return coeffIntBuf

	@getCoeffAsASNValueFromKey: (key) =>
		coeff = new wiz.framework.wizrsa.main.ASNinteger()
		coeffIntBuf = wiz.framework.wizrsa.main.getCoeffAsBufferFromKey(key)
		coeff.setIntBuffer(coeffIntBuf)
		return coeff

	@getPrivateSequenceFromKey: (key) =>
		version = wiz.framework.wizrsa.main.Version()
		modulus = wiz.framework.wizrsa.main.getModulusAsASNValueFromKey(key)
		publicExponent = wiz.framework.wizrsa.main.getPublicExponentAsASNValueFromKey(key)
		privateExponent = wiz.framework.wizrsa.main.getPrivateExponentAsASNValueFromKey(key)
		prime1 = wiz.framework.wizrsa.main.getPrime1AsASNValueFromKey(key)
		prime2 = wiz.framework.wizrsa.main.getPrime2AsASNValueFromKey(key)
		exponent1 = wiz.framework.wizrsa.main.getExponent1AsASNValueFromKey(key)
		exponent2 = wiz.framework.wizrsa.main.getExponent2AsASNValueFromKey(key)
		coeff = wiz.framework.wizrsa.main.getCoeffAsASNValueFromKey(key)

		privateSequence = [
			version
			modulus
			publicExponent
			privateExponent
			prime1
			prime2
			exponent1
			exponent2
			coeff
		]

		return privateSequence

	@getPublicSequenceFromKey: (key) =>
		modulus = wiz.framework.wizrsa.main.getModulusAsASNValueFromKey(key)
		publicExponent = wiz.framework.wizrsa.main.getPublicExponentAsASNValueFromKey(key)

		publicSequence = [
			modulus
			publicExponent
		]

		return publicSequence

	@getPrivateASNsequenceFromKey: (key) =>
		privateASNsequence = new wiz.framework.wizrsa.main.ASNsequence()
		privateSequence = wiz.framework.wizrsa.main.getPrivateSequenceFromKey(key)
		privateASNsequence.setSequence(privateSequence)
		return privateASNsequence

	@getPublicASNsequenceFromKey: (key) =>
		publicASNsequence = new wiz.framework.wizrsa.main.ASNsequence()
		publicSequence = wiz.framework.wizrsa.main.getPublicSequenceFromKey(key)
		publicASNsequence.setSequence(publicSequence)
		return publicASNsequence

	@getPrivateDERfromKey: (key) =>
		privateASNsequence = wiz.framework.wizrsa.main.getPrivateASNsequenceFromKey(key)
		privateDER = privateASNsequence.encode()
		return privateDER

	@getPublicBitStringFromKey: (key) =>
		publicSequence = wiz.framework.wizrsa.main.getPublicASNsequenceFromKey(key)
		publicBitString = publicSequence.encode()
		return publicBitString

	@getPublicDERfromKey: (key) =>
		publicBitString = wiz.framework.wizrsa.main.getPublicBitStringFromKey(key)
		algID = wiz.framework.wizrsa.DERalgID()
		doubleZero = new Buffer("00", 'hex') # padding

		publicBitStringSequence = new wiz.framework.wizrsa.main.ASNbitString()
		publicBitStringSequence.value = Buffer.concat([
			doubleZero
			publicBitString
		])

		publicBitStringSequenceEncoded = publicBitStringSequence.encode()

		publicDER = new wiz.framework.wizrsa.main.ASNsequence()
		publicDER.value = Buffer.concat([
			algID
			publicBitStringSequenceEncoded
		])

		return publicDER.encode()

	@getPrivatePEMfromKey: (key) =>
		keyParser = wiz.framework.wizrsa.parser.privateKey.fromRSAkey(key)
		return keyParser.toPEMbuffer()
		#privateDER = wiz.framework.wizrsa.main.getPrivateDERfromKey(key)
		#privatePEM = rsa.linebrk(privateDER.toString('base64'),64)
		#privatePEMout = '-----BEGIN RSA PRIVATE KEY-----\n'
		#privatePEMout += privatePEM + '\n'
		#privatePEMout += '-----END RSA PRIVATE KEY-----'
		#return privatePEMout

	@getPublicPEMfromKey: (key) =>
		publicDER = wiz.framework.wizrsa.main.getPublicDERfromKey(key)
		publicPEM = rsa.linebrk(publicDER.toString('base64'),64)
		publicPEMout = '-----BEGIN PUBLIC KEY-----\n'
		publicPEMout += publicPEM + '\n'
		publicPEMout += '-----END PUBLIC KEY-----'
		return publicPEMout

class wiz.framework.wizrsa.main.asnvalue
	constructor: (@tag) ->

	setIntBuffer: (value) =>
		if value.length > 1
			firstbyte = value[0]
			if firstbyte & 0x80

				# First bit is set but it needs to be 0
				zerobit = new Buffer("00", "hex")
				value = Buffer.concat([zerobit, value])
		@value = value

	setSequence: (value) =>
		result = value[0].encode()
		i = 1
		while i < value.length
			result = Buffer.concat([result, value[i].encode()])
			i++
		@value = result

	encode: () =>
		result = @tag
		size = @value.length

		# Calculate how many bytes are needed to store the value of size
		if size < 127
			sizehex = new Buffer("0" + size.toString(16), "hex")
			result = Buffer.concat([result, sizehex])
		else
			hexstring = size.toString(16)

			# pads the hexstring to always have even number of bytes
			hexstring = "0" + hexstring	if hexstring.length % 2 is 1

			# create new buffer
			sizeBuf = new Buffer(hexstring, "hex")

			# 0x80 + (2 or 3)
			firstByte = 0x80 + sizeBuf.length
			fb = new Buffer(firstByte.toString(16), "hex")
			result = Buffer.concat([result, fb, sizeBuf])
		result = Buffer.concat([result, @value])
		return result

# vim: foldmethod=marker wrap
