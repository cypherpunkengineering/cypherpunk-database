# copyright 2013 wiz technologies inc.

require '..'
require '../database/s3'

wiz.package 'wiz.framework.http.database'

class wiz.framework.http.database.s3 extends wiz.framework.database.s3
	fail: (req, res, err) =>
		wiz.log.error "S3 request failed"
		res.statusCode = 500
		res.end()

	createNewBucket: (req, res, bucket) =>
		super bucket, (out) =>
			return res.send out.statusCode if out
			return @fail req, res, 'missing response'

	issueCredentials: (req, res, name, email, userKey, cb) =>
		super name, email, userKey, (out) =>
			if not out or not out.key_id or not out.key_secret
				return @fail req, res, 'missing credentials'
			cb out

	listBucketContents: (req, res, bucket, path, cb) =>
		super bucket, path, (contents) =>

# vim: foldmethod=marker wrap
