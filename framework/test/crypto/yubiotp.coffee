require '../..'

require '../../crypto/otp'
require '../../crypto/convert'

modhex = 'vveenevlnujflcviruniirrunirfujflicdcvirunrfr'

hex = wiz.framework.crypto.convert.modhex2hex(modhex)
console.log "converted #{modhex} to #{hex}"

modhex2 = wiz.framework.crypto.convert.hex2modhex(hex)
console.log "converted #{hex} to #{modhex2}"

if modhex == modhex2
	console.log 'PASS'
else
	console.log 'FAIL'
