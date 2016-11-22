# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'

mysql = require('mysql')

wiz.package 'wiz.framework.database.mysql'

class wiz.framework.database.mysql.driver

	debug: false
	db: null
	config:
		connectionLimit: 10
		hostname: null
		username: null
		password: null
		database: null

	constructor: (@config) ->
		@config.host = @config.hostname
		@config.user = @config.username

	init: (cb) => #{{{ init driver instance
		@db = mysql.createPool(@config)
		###
		@connect (err) =>
			wiz.log.err "error connecting to database mysql://#{@config.host}/#{@config.database}: #{err}" if err
			wiz.log.info "connected to database mysql://#{@config.host}/#{@config.database}: #{@db.threadId}" if not err
			cb(err) if cb
		###
	#}}}

	connect: (cb) => #{{{ connect and auth to mysql database
		try
			@db.connect()
		catch e
			return cb "mysql.connect(#{@config.hostname}) failed: #{e}"

		# no error
		return cb(null)
	#}}}

	query: (q, cb) => #{{{ connect and auth to mysql database
		wiz.log.debug q
		try
			return @db.query q, (err, rows, fields) =>
				wiz.log.err "MySQL Error: #{err}" if err
				return cb(err, rows, fields) if cb
		catch e
			return cb "mysql.query(#{q}) failed: #{e}"
	#}}}

# vim: foldmethod=marker wrap
