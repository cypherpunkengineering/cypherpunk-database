# copyright 2013 wiz technologies inc.

require '../..'
require '../../crypto/hash'

wiz.package 'wiz.framework.http.database.base'

class wiz.framework.http.database.base.dbobj #{{{

	constructor: () ->
		# implement in child class

	immutable: false

	toDB: (req) ->
		# add timestamps
		@updated ?= wiz.framework.util.datetime.unixFullTS()
		@created ?= @updated
		# create unique id using headers/session data as salt
		@id ?= wiz.framework.crypto.hash.digest
			payload: this
			headers: req.headers
			session: req.session
		return this

	toJSON: () =>
		return this
#}}}

# vim: foldmethod=marker wrap
