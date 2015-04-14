# copyright 2013 J. Maurice <j@wiz.biz>

require '..'
require '../database/mongo/driver'

wiz.package 'wiz.framework.daemon.mongo'

class wiz.framework.daemon.mongo.driver extends wiz.framework.database.mongo.driver

	debug: false

	constructor: (@parent, @config, @serverOptions, @dbOptions) -> #{{{
		super()
	#}}}
	init: (cb) => #{{{
		# just test database connection
		super (err) =>
			if @client
				wiz.log.debug 'initial database connection OK' if @debug
				cb() if cb
	#}}}

	connect: (cb) => #{{{
		wiz.log.debug "connecting to mongo database #{@config.database}" if @debug
		super (err) =>
			# call cb even if err
			if not @client or err
				wiz.log.err "unable to connect to mongo database #{@config.database} #{err}"
			cb err
	#}}}
	disconnect: () => #{{{
		wiz.log.debug "disconnecting from mongo database #{@config.database}" if @debug
		super()
	#}}}

	collection: (collectionName, cb) => #{{{
		super collectionName, (err, collection) =>
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

# vim: foldmethod=marker wrap
