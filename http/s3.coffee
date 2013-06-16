# copyright 2013 wiz technologies inc.

require '..'
require '../database/s3'

wiz.package 'wiz.framework.http.database'

class wiz.framework.http.database.s3 extends wiz.framework.database.s3

	createNewBucket: (req, res, bucket) =>
		super bucket, (out) =>
			return res.send out.statusCode if out
			wiz.log.error "S3 request failed"
			return res.send 500

	issueCredentials: (req, res, name, email, userKey, cb) =>
		super name, email, userKey, (out) =>
			if not out or not out.key_id or not out.key_secret
				wiz.log.error "S3 request failed"
				return res.send 500
			cb out

# vim: foldmethod=marker wrap
