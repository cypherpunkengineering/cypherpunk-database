# copyright 2015 J. Maurice <j@wiz.biz>

require '..'

fs = require('fs')
ssh = require('ssh2').Client

wiz.package 'wiz.framework.daemon.sshClient'

class wiz.framework.daemon.sshClient
	#{{{ member vars
	cb: null
	outputFilename: null # optionally save output to file
	#}}}
	config: #{{{
		host: ''
		port: 0
		username: ''
		password: ''
	#}}}

	# probably dont need to touch these too much
	constructor: (args = {}) -> #{{{
		@config.host = args.host or '127.0.0.1'
		@config.port = args.port or 22
		@config.username = args.username or 'admin'
		@config.password = args.password or 'password'
		@cb = args.cb or () ->
	#}}}
	init: () => #{{{
		@conn = new ssh()
		@conn.on 'ready', @onReady
		@conn.connect(@config)
	#}}}
	onReady: () => #{{{
		wiz.log.info "SSH connection to #{@config.host} established"
		@conn.shell(@onShellReady)
	#}}}
	onShellReady: (err, @stream) => #{{{
		if err
			wiz.log.err err
			@conn.end()

		@stdout = ''
		@stderr = ''

		@stream.on 'close', @onStreamClose
		@stream.on 'data', @onStreamData
		@stream.stderr.on 'data', @onStreamStdErrData

		@sendCommands()
	#}}}
	onStreamClose: () => #{{{
		if @outputFilename
			fs.writeFileSync @outputFilename, @stdout
		@parseResult()
		@conn.end()
	#}}}
	onStreamData: (data) => #{{{
		@stdout += data
	#}}}
	onStreamStdErrData: (data) => #{{{
		@stderr += data
	#}}}

	# probably want to implement these in child class
	sendCommands: () => #{{{
		cb = () =>
			@stream.close()
		setTimeout cb, 10 * 1000
	#}}}
	parseResult: () => #{{{
		@cb(@stdout)
	#}}}

# vim: foldmethod=marker wrap
