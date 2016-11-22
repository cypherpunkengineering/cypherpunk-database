require '../..'
require '../../database/mysql/driver'

wiz.package 'wiz.framework.http.database.mysql'

#TODO: rewrite so all args are properties of "args" object?

class wiz.framework.http.database.mysql.driver extends wiz.framework.database.mysql.driver
	constructor: (@server, @parent, @config) ->
		super(@config)
		@init()

	query: (req, res, q, cb) =>
		super q, (err, rows, fields) =>
			return cb(req, res, err, rows, fields) if cb
			return res.send 500, "Database error" if err
			return res.send 200

# vim: foldmethod=marker wrap
