# copyright 2013 wiz technologies inc.

require '..'
require '../database/mongo'

wiz.package 'wiz.framework.daemon.mongo'

# mongo class
class wiz.framework.daemon.mongo extends wiz.framework.database.mongo

	verbose : false

	constructor : (@parent, @config, @serverOptions, @dbOptions) ->
		super()
		@init()

	init : () =>
		# just test database connection
		super (err, client) =>
			if client
				if @verbose then wiz.log.debug 'initial database connection OK'
				@disconnect(client)

	connect : (cb) =>
		if @verbose then wiz.log.debug "connecting to mongo database #{@config.database}"
		super (err, client) =>
			# call cb even if err
			if not client or err
				wiz.log.err "unable to connect to mongo database #{@config.database} #{err}"
			cb err, client

	disconnect : (client) =>
		if @verbose then wiz.log.debug "disconnecting from mongo database #{@config.database}"
		super (client)

	collection : (client, collectionName, stayOpen, cb) =>
		super client, collectionName, stayOpen, (err, collection) =>
			# only call cb if we have collection
			if not collection or err
				wiz.log.err "unable to retrieve collection #{@config.database}.#{collectionName} #{err}"
				return
			cb err, collection

	# date like this: 2012.04.01
	dayFromDate : (date) ->
		key = date.getFullYear()
		key += '.' + ('0' + date.getMonth()).slice(-2)
		key += '.' + ('0' + date.getDate()).slice(-2)
		return key

	# date like this: 2012.04.01.09
	dayhourFromDate : (date) ->
		# key = dayFromDate(date)
		key = date.getFullYear()
		key += '.' + ('0' + date.getMonth()).slice(-2)
		key += '.' + ('0' + date.getDate()).slice(-2)
		key += '.' + ('0' + date.getHours()).slice(-2)
		return key

	# for storing javascript methods in database
	saveJS : (methodsToSave) =>
		wiz.log.debug 'preparing to save JS to database'
		@connect (err, client) =>
			@collection client, 'system.js', false, (err, systemJS) =>
				for methodName, methodCode of methodsToSave
					wiz.log.debug "saving #{methodName} to database"
					# save db methods as stored JS
					systemJS.save
						'_id' : methodName
						'value' : @code(methodCode)

# vim: foldmethod=marker wrap
