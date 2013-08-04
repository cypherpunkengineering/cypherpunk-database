require '../..'
require '../../crypto/otp'

s = wiz.framework.crypto.otp.generateSecret(20)

console.log "SECRET base16: #{s.hex}"
console.log "SECRET base32: #{s.base32}"

secret = s.hex
#secret = ''

keybuf = new Buffer(secret, 'hex')
totp = wiz.framework.crypto.otp.generateTOTP(keybuf)
hotp = wiz.framework.crypto.otp.generateHOTP(keybuf, 0)

console.log "TOTP: #{totp}"
console.log "HOTP: #{hotp}"
