# copyright 2013 wiz technologies inc.

require '..'

rsa = require './rsa'
asnvalue = require './asnvalue'

wiz.package 'wiz.framework.wizrsa'

TAG_INTEGER = new Buffer('02', 'hex')
TAG_BITSTRING = new Buffer('03','hex')
TAG_SEQUENCE = new Buffer('30','hex')

DER_ALGORITHM_ID = '300d06092a864886f70d0101010500'

class wiz.framework.wizrsa

	@ASNinteger: () =>
		return new asnvalue.ASNValue(TAG_INTEGER)

	@ASNsequence: () =>
		return new asnvalue.ASNValue(TAG_SEQUENCE)

	@ASNbitString: () =>
		return new asnvalue.ASNValue(TAG_BITSTRING)

	@DERalgID: () =>
		return new Buffer(DER_ALGORITHM_ID, 'hex')

	@Version: () =>
		version = new wiz.framework.wizrsa.ASNinteger()
		pbuf = new Buffer("00", 'hex')
		version.setIntBuffer(pbuf)
		return version

	@doPaddingOnHexstring: (hexstring) =>
		if hexstring.length % 2 == 1
			hexstring = "0" + hexstring
		return hexstring

	@loadPrivateKeyFromPEMstr: (privatePEM) =>
		privateKey = new rsa.Key()
		privateKey.readPrivateKeyFromPEMString(privatePEM)
		return privateKey

	@loadPublicKeyFromPEMstr: (publicPEM) =>
		publicKey = new rsa.Key()
		publicKey.readPublicKeyFromPEMString(publicPEM)
		return publicKey

	# bits is base 10
	# publicExponent is base 16
	@generateKeyPair: (bits = 2048, publicExponent = "10001") =>
		keypair = new rsa.Key()
		keypair.generate(bits, publicExponent)
		return keypair

	@getModulusAsBufferFromKey: (key) =>
		# Convert BigInteger to binary data
		modulus = wiz.framework.wizrsa.doPaddingOnHexstring key.n.toString(16)
		modulusIntBuf = new Buffer(modulus, 'hex')
		return modulusIntBuf

	@getModulusAsASNValueFromKey: (key) =>
		# extract modulus (n) from private key
		modulus = new wiz.framework.wizrsa.ASNinteger()
		modulus.setIntBuffer(wiz.framework.wizrsa.getModulusAsBufferFromKey(key))
		return modulus

	@getPublicExponentAsBufferFromKey: (key) =>
		# extract public exponent (e) from private key
		publicExponentHexString = wiz.framework.wizrsa.doPaddingOnHexstring(key.e.toString(16))
		publicExponentIntBuf = new Buffer(publicExponentHexString, 'hex')
		return publicExponentIntBuf

	@getPublicExponentAsASNValueFromKey: (key) =>
		publicExponent = new wiz.framework.wizrsa.ASNinteger()
		publicExponentIntBuf = wiz.framework.wizrsa.getPublicExponentAsBufferFromKey(key)
		publicExponent.setIntBuffer(publicExponentIntBuf)
		return publicExponent

	@getPrivateExponentAsBufferFromKey: (key) =>
		# extract private exponent (e) from private key
		privateExponentHexString = wiz.framework.wizrsa.doPaddingOnHexstring(key.d.toString(16))
		privateExponentIntBuf = new Buffer(privateExponentHexString, 'hex')
		return privateExponentIntBuf

	@getPrivateExponentAsASNValueFromKey: (key) =>
		privateExponent = new wiz.framework.wizrsa.ASNinteger()
		privateExponentIntBuf = wiz.framework.wizrsa.getPrivateExponentAsBufferFromKey(key)
		privateExponent.setIntBuffer(privateExponentIntBuf)
		return privateExponent

	@getPrime1AsBufferFromKey: (key) =>
		# extract prime1 exponent (e) from prime1 key
		prime1HexString = wiz.framework.wizrsa.doPaddingOnHexstring(key.p.toString(16))
		prime1IntBuf = new Buffer(prime1HexString, 'hex')
		return prime1IntBuf

	@getPrime1AsASNValueFromKey: (key) =>
		prime1 = new wiz.framework.wizrsa.ASNinteger()
		prime1IntBuf = wiz.framework.wizrsa.getPrime1AsBufferFromKey(key)
		prime1.setIntBuffer(prime1IntBuf)
		return prime1

	@getPrime2AsBufferFromKey: (key) =>
		# extract prime2 exponent (e) from prime2 key
		prime2HexString = wiz.framework.wizrsa.doPaddingOnHexstring(key.q.toString(16))
		prime2IntBuf = new Buffer(prime2HexString, 'hex')
		return prime2IntBuf

	@getPrime2AsASNValueFromKey: (key) =>
		prime2 = new wiz.framework.wizrsa.ASNinteger()
		prime2IntBuf = wiz.framework.wizrsa.getPrime2AsBufferFromKey(key)
		prime2.setIntBuffer(prime2IntBuf)
		return prime2

	@getExponent1AsBufferFromKey: (key) =>
		# extract exponent1 exponent (e) from exponent1 key
		exponent1HexString = wiz.framework.wizrsa.doPaddingOnHexstring(key.dmp1.toString(16))
		exponent1IntBuf = new Buffer(exponent1HexString, 'hex')
		return exponent1IntBuf

	@getExponent1AsASNValueFromKey: (key) =>
		exponent1 = new wiz.framework.wizrsa.ASNinteger()
		exponent1IntBuf = wiz.framework.wizrsa.getExponent1AsBufferFromKey(key)
		exponent1.setIntBuffer(exponent1IntBuf)
		return exponent1

	@getExponent2AsBufferFromKey: (key) =>
		# extract exponent2 exponent (e) from exponent2 key
		exponent2HexString = wiz.framework.wizrsa.doPaddingOnHexstring(key.dmq1.toString(16))
		exponent2IntBuf = new Buffer(exponent2HexString, 'hex')
		return exponent2IntBuf

	@getExponent2AsASNValueFromKey: (key) =>
		exponent2 = new wiz.framework.wizrsa.ASNinteger()
		exponent2IntBuf = wiz.framework.wizrsa.getExponent2AsBufferFromKey(key)
		exponent2.setIntBuffer(exponent2IntBuf)
		return exponent2

	@getCoeffAsBufferFromKey: (key) =>
		# extract coeff exponent (e) from coeff key
		coeffHexString = wiz.framework.wizrsa.doPaddingOnHexstring(key.coeff.toString(16))
		coeffIntBuf = new Buffer(coeffHexString, 'hex')
		return coeffIntBuf

	@getCoeffAsASNValueFromKey: (key) =>
		coeff = new wiz.framework.wizrsa.ASNinteger()
		coeffIntBuf = wiz.framework.wizrsa.getCoeffAsBufferFromKey(key)
		coeff.setIntBuffer(coeffIntBuf)
		return coeff

	@getPrivateSequenceFromKey: (key) =>
		version = wiz.framework.wizrsa.Version()
		modulus = wiz.framework.wizrsa.getModulusAsASNValueFromKey(key)
		publicExponent = wiz.framework.wizrsa.getPublicExponentAsASNValueFromKey(key)
		privateExponent = wiz.framework.wizrsa.getPrivateExponentAsASNValueFromKey(key)
		prime1 = wiz.framework.wizrsa.getPrime1AsASNValueFromKey(key)
		prime2 = wiz.framework.wizrsa.getPrime2AsASNValueFromKey(key)
		exponent1 = wiz.framework.wizrsa.getExponent1AsASNValueFromKey(key)
		exponent2 = wiz.framework.wizrsa.getExponent2AsASNValueFromKey(key)
		coeff = wiz.framework.wizrsa.getCoeffAsASNValueFromKey(key)

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
		modulus = wiz.framework.wizrsa.getModulusAsASNValueFromKey(key)
		publicExponent = wiz.framework.wizrsa.getPublicExponentAsASNValueFromKey(key)

		publicSequence = [
			modulus
			publicExponent
		]

		return publicSequence

	@getPrivateASNsequenceFromKey: (key) =>
		privateASNsequence = new wiz.framework.wizrsa.ASNsequence()
		privateSequence = wiz.framework.wizrsa.getPrivateSequenceFromKey(key)
		privateASNsequence.setSequence(privateSequence)
		return privateASNsequence

	@getPublicASNsequenceFromKey: (key) =>
		publicASNsequence = new wiz.framework.wizrsa.ASNsequence()
		publicSequence = wiz.framework.wizrsa.getPublicSequenceFromKey(key)
		publicASNsequence.setSequence(publicSequence)
		return publicASNsequence

	@getPrivateDERfromKey: (key) =>
		privateASNsequence = wiz.framework.wizrsa.getPrivateASNsequenceFromKey(key)
		privateDER = privateASNsequence.encode()
		return privateDER

	@getPublicBitStringFromKey: (key) =>
		publicSequence = wiz.framework.wizrsa.getPublicASNsequenceFromKey(key)
		publicBitString = publicSequence.encode()
		return publicBitString

	@getPublicDERfromKey: (key) =>
		publicBitString = wiz.framework.wizrsa.getPublicBitStringFromKey(key)
		algID = wiz.framework.wizrsa.DERalgID()
		doubleZero = new Buffer("00", 'hex') # padding

		publicBitStringSequence = new wiz.framework.wizrsa.ASNbitString()
		publicBitStringSequence.value = Buffer.concat([
			doubleZero
			publicBitString
		])

		publicBitStringSequenceEncoded = publicBitStringSequence.encode()

		publicDER = new wiz.framework.wizrsa.ASNsequence()
		publicDER.value = Buffer.concat([
			algID
			publicBitStringSequenceEncoded
		])

		return publicDER.encode()

	@getPrivatePEMfromKey: (key) =>
		privateDER = wiz.framework.wizrsa.getPrivateDERfromKey(key)
		privatePEM = rsa.linebrk(privateDER.toString('base64'),64)
		privatePEMout = '-----BEGIN RSA PRIVATE KEY-----\n'
		privatePEMout += privatePEM + '\n'
		privatePEMout += '-----END RSA PRIVATE KEY-----'
		return privatePEMout

	@getPublicPEMfromKey: (key) =>
		publicDER = wiz.framework.wizrsa.getPublicDERfromKey(key)
		publicPEM = rsa.linebrk(publicDER.toString('base64'),64)
		publicPEMout = '-----BEGIN PUBLIC KEY-----\n'
		publicPEMout += publicPEM + '\n'
		publicPEMout += '-----END PUBLIC KEY-----'
		return publicPEMout

# vim: foldmethod=marker wrap
