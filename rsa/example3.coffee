crypto = require('crypto');
fs = require 'fs'
rsa = require("./rsa");

# for example, jason is server, mike is client
jasonpem =
	priv: fs.readFileSync 'jason/private.pem'
	pub: fs.readFileSync 'jason/public.pem'

mikepem =
	priv: fs.readFileSync 'mike/private.pem'
	pub: fs.readFileSync 'mike/public.pem'

jasonrsa = new rsa.Key()
jasonrsa.readPrivateKeyFromPEMString(mikepem.priv.toString())
#jasonrsa.readPublicKeyFromPEMString(jasonpem.pub.toString())
#console.log jasonrsa.n

mikersa = new rsa.Key()
#mikersa.generate(1024, "10001");
#mikersa.readPrivateKeyFromPEMString(mikepem.priv.toString())
mikersa.readPublicKeyFromPEMString(mikepem.pub.toString())

# random data used for challenge
try
	buf = crypto.randomBytes(64).toString('utf8')
	console.log('Have %d bytes of random data: %s', buf.length, buf);
catch ex
#handle error

# encrypt bytes to clients public key
encrypted = mikersa.encrypt(buf)
decrypted = jasonrsa.decrypt(encrypted)

console.log decrypted.toString('utf8')
#jason = crypto.getDiffieHellman('modp5');
#mike = crypto.getDiffieHellman('modp5');
#
#jason.generateKeys();
#mike.generateKeys();
#
#jason_secret = jason.computeSecret(mike.getPublicKey(), null, 'binary');
#mike_secret = mike.computeSecret(jason.getPublicKey(), null, 'binary');
#
#rsa = require("rsa");
#key = new rsa.Key();
#key.generate(1024, "10001");
#console.log key
#c = crypto.createCipher('aes256', jason_secret)
#encryptedkey = c.update(JSON.stringify(key), 'utf8', 'base64')
#encryptedkey += c.final('base64')
#console.log "encrypted " + encryptedkey
#
#d = crypto.createDecipher('aes256', mike_secret)
#decryptedkey = d.update(encryptedkey, 'base64', 'utf8')
#decryptedkey += d.final('utf8')
#
#JSONkey = JSON.parse(decryptedkey)
#console.log JSON.parse(decryptedkey)
#fs.writeFile "test.out", decryptedkey, 'utf8', (err) =>
#	if err
#		wiz.log.err "Error writing file #{fn}: #{err}"
#		return
#	#wiz.log.info "Successfully wrote file #{fn}"
#
#
#
##console.log("Key:\n");
#
##encrypted = key.encrypt(message);
##console.log("Encrypted:\n" + rsa.linebrk(encrypted, 64) + "\n" );
#
##decrypted = key.decrypt(encrypted);
##console.log("Decrypted:" + rsa.linebrk(decrypted, 64) + "\n");
#
##sig = key.signString(message, "sha256");
##console.log("String signature: \n" + rsa.linebrk(sig, 64));
#
##pubkey = new rsa.Key();
##pubkey.n = key.n;
##pubkey.e = key.e;
#
##verified = pubkey.verifyString(message, sig);
#
##console.log("Verfied: " + verified);
