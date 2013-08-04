require '../..'
require '../../util/otp'

s = wiz.framework.util.otp.generateSecret(20)

console.log "SECRET base16: #{s.hex}"
console.log "SECRET base32: #{s.base32}"

secret = s.hex
#secret = ''

keybuf = new Buffer(secret, 'hex')
totp = wiz.framework.util.otp.totp(keybuf)
hotp = wiz.framework.util.otp.hotp(keybuf, 0)

console.log "TOTP: #{totp}"
console.log "HOTP: #{hotp}"
