# copyright 2013 J. Maurice <j@wiz.biz>

require '..'
require '../database/mongo/driver'

wiz.package 'wiz.framework.daemon.mongo'

class wiz.framework.daemon.mongo.driver extends wiz.framework.database.mongo.driver

	debug: false

	constructor : (@parent, @config, @serverOptions, @dbOptions) -> #{{{
		super()
	#}}}
	init : () => #{{{
		# just test database connection
		super (err, client) =>
			if client
				wiz.log.debug 'initial database connection OK' if @debug
				@disconnect(client)
	#}}}

	connect : (cb) => #{{{
		wiz.log.debug "connecting to mongo database #{@config.database}" if @debug
		super (err, client) =>
			# call cb even if err
			if not client or err
				wiz.log.err "unable to connect to mongo database #{@config.database} #{err}"
			cb err, client
	#}}}
	disconnect: (client) => #{{{
		wiz.log.debug "disconnecting from mongo database #{@config.database}" if @debug
		super (client)
	#}}}

	collection: (collectionName, cb) => #{{{
		@connect (err, client) =>
			return cb(err, null) if err or not client
			super client, collectionName, (err, collection) =>
				if err or not collection
					wiz.log.err "unable to retrieve collection #{@config.database}.#{collectionName}: #{err}"
					return cb(err, null)

				return cb(null, collection)
	#}}}

	dayFromDate: (date) -> #{{{ date like this: 2012.04.01
		key = date.getFullYear()
		key += '.' + ('0' + (date.getMonth() + 1)).slice(-2)
		key += '.' + ('0' + date.getDate()).slice(-2)
		return key
	#}}}
	dayhourFromDate: (date) -> #{{{ date like this: 2012.04.01.09
		# key = dayFromDate(date)
		key = date.getFullYear()
		key += '.' + ('0' + date.getMonth()).slice(-2)
		key += '.' + ('0' + date.getDate()).slice(-2)
		key += '.' + ('0' + date.getHours()).slice(-2)
		return key
	#}}}

	saveJS: (methodsToSave) => #{{{ for storing javascript methods in database
		wiz.log.debug 'preparing to save JS to database'
		@collection 'system.js', (err, systemJS) =>
			for methodName, methodCode of methodsToSave
				@saveJSone systemJS, methodName, methodCode
	#}}}
	saveJSone: (systemJS, methodName, methodCode) => #{{{ for storing javascript methods in database
		wiz.log.debug "saving #{methodName} to database"
		# save db methods as stored JS
		objToSave =
			'_id' : methodName
			'value' : @code(methodCode)
		opts =
			'writeConcern':
				w: "majority"
				wtimeout: 5000
		systemJS.save objToSave, opts, (res) =>
			wiz.log.debug "callback from saving #{methodName} to database: #{res}"
	#}}}

# vim: foldmethod=marker wrap
