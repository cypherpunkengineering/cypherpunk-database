# copyright 2013 wiz technologies inc.

require '..'

MySQL = require 'mysql'

wiz.package 'wiz.framework.database.mysql'

class wiz.framework.database.mysql
	client : null
	config :
		host : ''
		user : ''
		password : ''

	constructor : (@config) ->
		@client = new MySQL.Client()
		@client.host = @config.hostname
		@client.user = @config.username
		@client.password = @config.password

# vim: foldmethod=marker wrap
