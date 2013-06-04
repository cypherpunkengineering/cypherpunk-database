require '..'
require '../database/s3'

fs = require 'fs'

wiz.app 'test'

s3 = new wiz.framework.database.s3
	port: 443
	key: ''
	secret: ''

s3.bucketList (res) =>
	console.log res
	if res and res.ListAllMyBucketsResult and res.ListAllMyBucketsResult.Buckets
		for bucket in res.ListAllMyBucketsResult.Buckets
			if bucket.Bucket
				bucketList = bucket.Bucket
				for b in bucket.Bucket
					if b.Name
						for n in b.Name
							console.log n
							s3.getParse n, '/', (res2) =>
								console.log res2
								if res2 and res2.ListBucketResult and res2.ListBucketResult.Contents
									for i in res2.ListBucketResult.Contents
										console.log i
										fd = fs.createWriteStream i.Key[0], { flags: 'w', encoding: 'binary' }
										s3.get n, i.Key[0], (res3) =>
											console.log res3.headers['content-type']
											res3.on 'end', (e) =>
												fd.end()
											res3.pipe fd
