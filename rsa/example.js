crypto = require('crypto');
fs = require 'fs'
jason = crypto.getDiffieHellman('modp5');
mike = crypto.getDiffieHellman('modp5');

jason.generateKeys();
mike.generateKeys();

jason_secret = jason.computeSecret(mike.getPublicKey(), null, 'binary');
mike_secret = mike.computeSecret(jason.getPublicKey(), null, 'binary');

rsa = require("rsa");
key = new rsa.Key();
key.generate(1024, "10001");
console.log key
c = crypto.createCipher('aes256', jason_secret)
encryptedkey = c.update(JSON.stringify(key), 'utf8', 'base64')
encryptedkey += c.final('base64')
console.log "encrypted " + encryptedkey

d = crypto.createDecipher('aes256', mike_secret)
decryptedkey = d.update(encryptedkey, 'base64', 'utf8')
decryptedkey += d.final('utf8')

JSONkey = JSON.parse(decryptedkey)
console.log JSON.parse(decryptedkey)
fs.writeFile "test.out", decryptedkey, 'utf8', (err) =>
	if err
		wiz.log.err "Error writing file #{fn}: #{err}"
		return
	#wiz.log.info "Successfully wrote file #{fn}"



#console.log("Key:\n");

#encrypted = key.encrypt(message);
#console.log("Encrypted:\n" + rsa.linebrk(encrypted, 64) + "\n" );

#decrypted = key.decrypt(encrypted);
#console.log("Decrypted:" + rsa.linebrk(decrypted, 64) + "\n");

#sig = key.signString(message, "sha256");
#console.log("String signature: \n" + rsa.linebrk(sig, 64));

#pubkey = new rsa.Key();
#pubkey.n = key.n;
#pubkey.e = key.e;

#verified = pubkey.verifyString(message, sig);

#console.log("Verfied: " + verified);
