require '../..'
require '../../http/server/base'
require '../../http/resource/base'
require '../../http/resource/root'
require '../../http/database/s3'

fs = require 'fs'

wiz.app 'testor'

s3 = new wiz.framework.database.s3
	host: 's3.wiz.biz'
	port: 443
	ssl: true
	key: fs.readFileSync 'S3key'
	secret: fs.readFileSync 'S3secret'

class resource extends wiz.framework.http.resource.base
	handler: (req, res) =>
		s3.listAllMyBuckets (buckets) =>
			for bucket in buckets
				if bucket.Name
					for bucketName in bucket.Name
						res.write bucketName + "\n"
			res.end()

class root extends wiz.framework.http.resource.root
	init: () =>
		@routeAdd new resource this, this, ''
		super()

class server extends wiz.framework.http.server.base
	init: () =>
		@root = new root this, null, ''
		super()

app = new server()
app.config.workers = 1
app.start()

# vim: foldmethod=marker wrap
