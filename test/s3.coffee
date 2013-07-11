require '..'
require '../database/s3'

fs = require 'fs'

wiz.app 'test'

s3 = new wiz.framework.database.s3
	host: 's3.wiz.biz'
	port: 443
	ssl: true
	key: fs.readFileSync 'S3key'
	secret: fs.readFileSync 'S3secret'

# move this stuff into base class, make proper methods for everything
s3.listAllMyBuckets (buckets) =>
	for bucket in buckets
		if bucket.Name
			for bucketName in bucket.Name
				console.log "Bucket found: #{bucketName}"
				s3.listBucketContents bucketName, '/', (objects) =>
					return if not objects
					console.log objects
					for obj in objects
						objectName = obj.Key[0]
						fd = fs.createWriteStream objectName, { flags: 'w', encoding: 'binary' }
						s3.getStream bucketName, objectName, (res3) =>
							return if not res3
							console.log res3.headers['content-type']
							res3.on 'end', (e) =>
								fd.end()
							res3.pipe fd
