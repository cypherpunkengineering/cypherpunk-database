require '..'
require '../database/s3'

wiz.app 'test'

s3 = new wiz.framework.database.s3
	port: 443
	key: ''
	secret: ''

s3.listBuckets (res) =>
	console.log res
