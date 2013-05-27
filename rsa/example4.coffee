crypto = require('crypto');
fs = require 'fs'
rsa = require("./rsa");
asnvalue = require("./asnvalue");
b64 = require("./b64");

TAG_INTEGER = new Buffer("02", 'hex');
TAG_BITSTREAM = new Buffer("03",'hex');
TAG_SEQUENCE = new Buffer("30",'hex');

# for example, jason is server, mike is client
jasonpem =
	priv: fs.readFileSync 'jason/private.pem'
	pub: fs.readFileSync 'jason/public.pem'
#
#mikepem =
#	priv: fs.readFileSync 'mike/private.pem'
#	pub: fs.readFileSync 'mike/public.pem'
#
jasonrsa = new rsa.Key()
jasonrsa.readPrivateKeyFromPEMString(jasonpem.priv.toString())
##jasonrsa.readPublicKeyFromPEMString(jasonpem.pub.toString())
##console.log jasonpem.priv.toString()
#
#mikersa = new rsa.Key()
##mikersa.generate(1024, "10001");
#mikersa.readPrivateKeyFromPEMString(mikepem.priv.toString())
#mikersa.readPublicKeyFromPEMString(mikepem.pub.toString())
#
modulus = new asnvalue.ASNValue(TAG_INTEGER)
# Convert BigInteger to binary data
intBuf = new Buffer(jasonrsa.n.toString(16), 'hex')
modulus.setIntBuffer(intBuf)
publicexponent = new asnvalue.ASNValue(TAG_INTEGER)
hexstring = jasonrsa.e.toString(16)
if hexstring.length % 2 == 1
	hexstring = "0" + hexstring
intBuf2 = new Buffer(hexstring, 'hex')
publicexponent.setIntBuffer(intBuf2)
keySequenceItems = [modulus, publicexponent]
keySequence = new asnvalue.ASNValue(TAG_SEQUENCE)
keySequence.setSequence(keySequenceItems)
bitstringvalue = keySequence.encode()
intBuf3 = new Buffer("00", 'hex')
bsv = Buffer.concat([intBuf3,bitstringvalue])
bitstring = new asnvalue.ASNValue(TAG_BITSTREAM)
bitstring.value = bsv
bv = new Buffer('300d06092a864886f70d0101010500', 'hex')
bodyvalue = Buffer.concat([bv,bitstring.encode()])
body = new asnvalue.ASNValue(TAG_SEQUENCE)
body.value = bodyvalue
publicder = body.encode()
cert = rsa.linebrk(publicder.toString('base64'),64)
console.log cert

version = new asnvalue.ASNValue(TAG_INTEGER)
pbuf = new Buffer("00", 'hex')
version.setIntBuffer(pbuf)
privmod = new asnvalue.ASNValue(TAG_INTEGER)
pintBuf = new Buffer(jasonrsa.n.toString(16), 'hex')
privmod.setIntBuffer(pintBuf)
ppublicexponent = new asnvalue.ASNValue(TAG_INTEGER)
phexstring = jasonrsa.e.toString(16)
if hexstring.length % 2 == 1
	hexstring = "0" + hexstring
pintBuf2 = new Buffer(hexstring, 'hex')
ppublicexponent.setIntBuffer(pintBuf2)
pprivateexponent = new asnvalue.ASNValue(TAG_INTEGER)
pintBuf3 = new Buffer(jasonrsa.d.toString(16), 'hex')
pprivateexponent.setIntBuffer(pintBuf3)
prime1 = new asnvalue.ASNValue(TAG_INTEGER)
pintBuf4 = new Buffer(jasonrsa.p.toString(16), 'hex')
prime1.setIntBuffer(pintBuf4)
prime2 = new asnvalue.ASNValue(TAG_INTEGER)
pintBuf5 = new Buffer(jasonrsa.q.toString(16), 'hex')
prime2.setIntBuffer(pintBuf5)
dmp1 = new asnvalue.ASNValue(TAG_INTEGER)
pintBuf6 = new Buffer(jasonrsa.dmp1.toString(16), 'hex')
dmp1.setIntBuffer(pintBuf6)
dmq1 = new asnvalue.ASNValue(TAG_INTEGER)
pintBuf7 = new Buffer(jasonrsa.dmq1.toString(16), 'hex')
dmq1.setIntBuffer(pintBuf7)
coeff = new asnvalue.ASNValue(TAG_INTEGER)
pintBuf8 = new Buffer(jasonrsa.coeff.toString(16), 'hex')
coeff.setIntBuffer(pintBuf8)

pkeySequenceItems = [version,privmod,ppublicexponent,pprivateexponent,prime1,prime2,dmp1,dmq1,coeff]
pkeySequence = new asnvalue.ASNValue(TAG_SEQUENCE)
pkeySequence.setSequence(pkeySequenceItems)

privateder = pkeySequence.encode()
console.log privateder.toString('hex')
pcert = rsa.linebrk(privateder.toString('base64'),64)
console.log pcert

## random data used for challenge
#try
#	buf = crypto.randomBytes(64).toString('utf8')
#	console.log('Have %d bytes of random data: %s', buf.length, buf);
#catch ex
##handle error
#
## encrypt bytes to clients public key
#encrypted = mikersa.encrypt(buf)
#decrypted = jasonrsa.decrypt(encrypted)
#
#console.log decrypted.toString('utf8')
##jason = crypto.getDiffieHellman('modp5');
##mike = crypto.getDiffieHellman('modp5');
##
##jason.generateKeys();
##mike.generateKeys();
##
##jason_secret = jason.computeSecret(mike.getPublicKey(), null, 'binary');
##mike_secret = mike.computeSecret(jason.getPublicKey(), null, 'binary');
##
##rsa = require("rsa");
##key = new rsa.Key();
##key.generate(1024, "10001");
##console.log key
##c = crypto.createCipher('aes256', jason_secret)
##encryptedkey = c.update(JSON.stringify(key), 'utf8', 'base64')
##encryptedkey += c.final('base64')
##console.log "encrypted " + encryptedkey
##
##d = crypto.createDecipher('aes256', mike_secret)
##decryptedkey = d.update(encryptedkey, 'base64', 'utf8')
##decryptedkey += d.final('utf8')
##
##JSONkey = JSON.parse(decryptedkey)
##console.log JSON.parse(decryptedkey)
##fs.writeFile "test.out", decryptedkey, 'utf8', (err) =>
##	if err
##		wiz.log.err "Error writing file #{fn}: #{err}"
##		return
##	#wiz.log.info "Successfully wrote file #{fn}"
##
##
##
##console.log("Key:\n");
##
##encrypted = key.encrypt(message);
##console.log("Encrypted:\n" + rsa.linebrk(encrypted, 64) + "\n" );
##
##decrypted = key.decrypt(encrypted);
##console.log("Decrypted:" + rsa.linebrk(decrypted, 64) + "\n");
##
##sig = key.signString(message, "sha256");
##console.log("String signature: \n" + rsa.linebrk(sig, 64));
##
##pubkey = new rsa.Key();
##pubkey.n = key.n;
##pubkey.e = key.e;
##
##verified = pubkey.verifyString(message, sig);
##
#console.log("Verfied: " + verified);
