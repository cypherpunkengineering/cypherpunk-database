crypto = require 'crypto'
fs = require 'fs'
rsa = require './rsa'
asnvalue = require './asnvalue'
b64 = require './b64'

TAG_INTEGER = new Buffer('02', 'hex')
TAG_BITSTREAM = new Buffer('03','hex')
TAG_SEQUENCE = new Buffer('30','hex')

class global.exampleJ

	@ASNinteger: () =>
		return new asnvalue.ASNValue(TAG_INTEGER)

	@ASNsequence: () =>
		return new asnvalue.ASNValue(TAG_SEQUENCE)

	@Version: () =>
		version = new exampleJ.ASNinteger()
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

	@generateKeyPair: (bits = 2048, publicExponent = 65537) =>
		keypair = new rsa.Key()
		keypair.generate(bits, publicExponent)
		return keypair

	@getModulusAsBufferFromKey: (key) =>
		# Convert BigInteger to binary data
		modulus = exampleJ.doPaddingOnHexstring key.n.toString(16)
		modulusIntBuf = new Buffer(modulus, 'hex')
		return modulusIntBuf

	@getModulusAsASNValueFromKey: (key) =>
		# extract modulus (n) from private key
		modulus = new exampleJ.ASNinteger()
		modulus.setIntBuffer(exampleJ.getModulusAsBufferFromKey(key))
		return modulus

	@getPublicExponentAsBufferFromKey: (key) =>
		# extract public exponent (e) from private key
		publicExponentHexString = exampleJ.doPaddingOnHexstring(key.e.toString(16))
		publicExponentIntBuf = new Buffer(publicExponentHexString, 'hex')
		return publicExponentIntBuf

	@getPublicExponentAsASNValueFromKey: (key) =>
		publicExponent = new exampleJ.ASNinteger()
		publicExponentIntBuf = exampleJ.getPublicExponentAsBufferFromKey(key)
		publicExponent.setIntBuffer(publicExponentIntBuf)
		return publicExponent

	@getPrivateExponentAsBufferFromKey: (key) =>
		# extract private exponent (e) from private key
		privateExponentHexString = exampleJ.doPaddingOnHexstring(key.d.toString(16))
		privateExponentIntBuf = new Buffer(privateExponentHexString, 'hex')
		return privateExponentIntBuf

	@getPrivateExponentAsASNValueFromKey: (key) =>
		privateExponent = new exampleJ.ASNinteger()
		privateExponentIntBuf = exampleJ.getPrivateExponentAsBufferFromKey(key)
		privateExponent.setIntBuffer(privateExponentIntBuf)
		return privateExponent

	@getPrime1AsBufferFromKey: (key) =>
		# extract prime1 exponent (e) from prime1 key
		prime1HexString = exampleJ.doPaddingOnHexstring(key.p.toString(16))
		prime1IntBuf = new Buffer(prime1HexString, 'hex')
		return prime1IntBuf

	@getPrime1AsASNValueFromKey: (key) =>
		prime1 = new exampleJ.ASNinteger()
		prime1IntBuf = exampleJ.getPrime1AsBufferFromKey(key)
		prime1.setIntBuffer(prime1IntBuf)
		return prime1

	@getPrime2AsBufferFromKey: (key) =>
		# extract prime2 exponent (e) from prime2 key
		prime2HexString = exampleJ.doPaddingOnHexstring(key.q.toString(16))
		prime2IntBuf = new Buffer(prime2HexString, 'hex')
		return prime2IntBuf

	@getPrime2AsASNValueFromKey: (key) =>
		prime2 = new exampleJ.ASNinteger()
		prime2IntBuf = exampleJ.getPrime2AsBufferFromKey(key)
		prime2.setIntBuffer(prime2IntBuf)
		return prime2

	@getExponent1AsBufferFromKey: (key) =>
		# extract exponent1 exponent (e) from exponent1 key
		exponent1HexString = exampleJ.doPaddingOnHexstring(key.dmp1.toString(16))
		exponent1IntBuf = new Buffer(exponent1HexString, 'hex')
		return exponent1IntBuf

	@getExponent1AsASNValueFromKey: (key) =>
		exponent1 = new exampleJ.ASNinteger()
		exponent1IntBuf = exampleJ.getExponent1AsBufferFromKey(key)
		exponent1.setIntBuffer(exponent1IntBuf)
		return exponent1

	@getExponent2AsBufferFromKey: (key) =>
		# extract exponent2 exponent (e) from exponent2 key
		exponent2HexString = exampleJ.doPaddingOnHexstring(key.dmq1.toString(16))
		exponent2IntBuf = new Buffer(exponent2HexString, 'hex')
		return exponent2IntBuf

	@getExponent2AsASNValueFromKey: (key) =>
		exponent2 = new exampleJ.ASNinteger()
		exponent2IntBuf = exampleJ.getExponent2AsBufferFromKey(key)
		exponent2.setIntBuffer(exponent2IntBuf)
		return exponent2

	@getCoeffAsBufferFromKey: (key) =>
		# extract coeff exponent (e) from coeff key
		coeffHexString = exampleJ.doPaddingOnHexstring(key.coeff.toString(16))
		coeffIntBuf = new Buffer(coeffHexString, 'hex')
		return coeffIntBuf

	@getCoeffAsASNValueFromKey: (key) =>
		coeff = new exampleJ.ASNinteger()
		coeffIntBuf = exampleJ.getCoeffAsBufferFromKey(key)
		coeff.setIntBuffer(coeffIntBuf)
		return coeff

	@getPrivateSequenceFromKey: (key) =>
		version = exampleJ.Version()
		modulus = exampleJ.getModulusAsASNValueFromKey(key)
		publicExponent = exampleJ.getPublicExponentAsASNValueFromKey(key)
		privateExponent = exampleJ.getPrivateExponentAsASNValueFromKey(key)
		prime1 = exampleJ.getPrime1AsASNValueFromKey(key)
		prime2 = exampleJ.getPrime2AsASNValueFromKey(key)
		exponent1 = exampleJ.getExponent1AsASNValueFromKey(key)
		exponent2 = exampleJ.getExponent2AsASNValueFromKey(key)
		coeff = exampleJ.getCoeffAsASNValueFromKey(key)

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

	@getPrivateASNsequenceFromKey: (key) =>
		privateASNsequence = new exampleJ.ASNsequence()
		privateSequence = exampleJ.getPrivateSequenceFromKey(key)
		privateASNsequence.setSequence(privateSequence)
		return privateASNsequence

	@getPrivateDERfromKey: (key) =>
		privateASNsequence = exampleJ.getPrivateASNsequenceFromKey(key)
		privateDER = privateASNsequence.encode()
		return privateDER

	@getPublicSequenceFromKey: (key) =>
		modulus = exampleJ.getModulusAsASNValueFromKey(key)
		publicExponent = exampleJ.getPublicExponentAsASNValueFromKey(key)

		publicSequence = [
			modulus
			publicExponent
		]

		return publicSequence

	@getPrivatePEMfromKey: (key) =>
		privateDER = exampleJ.getPrivateDERfromKey(key)
		privatePEM = rsa.linebrk(privateDER.toString('base64'),64)
		privatePEMout = '-----BEGIN RSA PRIVATE KEY-----\n'
		privatePEMout += privatePEM + '\n'
		privatePEMout += '-----END RSA PRIVATE KEY-----'
		return privatePEMout
