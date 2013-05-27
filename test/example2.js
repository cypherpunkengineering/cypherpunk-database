crypto = require('crypto');
fs = require 'fs'
jason = crypto.getDiffieHellman('modp5');
mike = crypto.getDiffieHellman('modp5');

jason.generateKeys();
mike.generateKeys();

jason_secret = jason.computeSecret(mike.getPublicKey(), null, 'binary');
mike_secret = mike.computeSecret(jason.getPublicKey(), null, 'binary');

jason =
	priv: fs.readFileSync 'jason/private.pem'
	pub: fs.readFileSync 'jason/public.pem'

rsa = require("./rsa");
key = new rsa.Key()
key.readPrivateKeyFromPEMString(jason.priv.toString())
encryptedtext = fs.readFileSync 'encrypted.txt'
text = encryptedtext.toString('hex')
#console.log text
#B64 = require("./b64.js")
#hextext = B64.hex2b64(encryptedtext.toString('base64'))
text2 = key.decrypt(text).toString()
console.log text2
