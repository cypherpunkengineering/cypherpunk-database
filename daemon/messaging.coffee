# wiz framework daemon daemon messaging classes
# copyright 2013 wiz technologies inc.

require '..'

wiz.package 'wiz.framework.daemon'

zmq = require 'zmq' # zero message queue
os = require 'os'

class wiz.framework.daemon.zmqsock

	linger: 0
	debug: false
	quiet: false
	binding: 'tcp://*:0'
	type: ''

	constructor: (@type, @binding) ->

	init: () => #{{{
		@sock = zmq.socket @type
		@sock.linger = @linger
		@sock.on 'error', @onError
		@sock.on 'message', @onRawMessage
	#}}}
	reinit: () => #{{{
		@sock.close()
		@init()
	#}}}
	onError: (msg) => #{{{
		wiz.log.debug "Error event #{msg}"
	#}}}
	onRawMessage: (rawmsg) => #{{{
		msg = new wiz.framework.daemon.message rawmsg
		if not msg or not msg.datum or not msg.datum.ts or not msg.datum.cmd
			wiz.log.err "RECV MSG ERROR: #{rawmsg}"
			@sendERR()
			return

		@logMessage 'RECV', msg

		switch msg.datum.cmd
			when 'PING'
				return @sendPong()
			when 'PONG'
				return @onPong msg
			when 'ERR'
				# avoid infinite loop by flagging socket error
				@err = true

		@onMessage msg
	#}}}
	logMessage: (tag, msg) => #{{{
		switch msg.datum.cmd
			when 'OK'
				return unless @debug
			when 'PING'
				return if tag is 'SEND'
				return unless @debug
			when 'PONG'
				return if tag is 'SEND'
				return unless @debug

		wiz.log.info "#{tag} #{msg.datum.from} #{msg.datum.cmd} #{msg.datum.ts}" unless @quiet
	#}}}

	onMessage: (msg) => # for child class
	onPong: (msg) => # for child class

	sendERR: () => #{{{
		return if @err # only send error msg once to avoid infinite loop
		@err = true
		err = new wiz.framework.daemon.message()
		err.datum.cmd = 'ERR'
		@send err
	#}}}
	sendOK: () => #{{{
		ok = new wiz.framework.daemon.message()
		ok.datum.cmd = 'OK'
		@send ok
	#}}}
	sendPing: () => #{{{
		ping = new wiz.framework.daemon.message()
		ping.datum.cmd = 'PING'
		@send ping
	#}}}
	sendPong: () => #{{{
		pong = new wiz.framework.daemon.message()
		pong.datum.cmd = 'PONG'
		@send pong
	#}}}
	send: (msg) => #{{{
		msg ?= 'OK'

		if not msg.datum
			wiz.log.debug "SEND MSG RAW: #{msg}" unless @quiet
			return @sock.send msg

		@logMessage 'SEND', msg
		@sock.send msg.toJSON()
	#}}}

class wiz.framework.daemon.zmqserver extends wiz.framework.daemon.zmqsock
	init: () => #{{{
		super()
		wiz.log.info "binding to #{@binding}"
		@sock.bind @binding, (err) =>
			if err
				wiz.log.crit "cannot bind socket to #{@binding}: #{err}"
				process.exit()
			# wiz.log.info "bound to #{@binding}"
	#}}}

class wiz.framework.daemon.zmqclient extends wiz.framework.daemon.zmqsock
	init: () => #{{{
		super()
		@sock.connect @binding
	#}}}

class wiz.framework.daemon.responder extends wiz.framework.daemon.zmqserver
	constructor: (@parent, @binding) -> #{{{
		super 'rep', @binding
	#}}}

class wiz.framework.daemon.requester extends wiz.framework.daemon.zmqclient
	constructor: (@parent, @binding) -> #{{{
		super 'req', @binding
	#}}}

class wiz.framework.daemon.publisher extends wiz.framework.daemon.zmqserver
	constructor: (@parent, @binding) -> #{{{
		super 'pub', @binding
	#}}}

class wiz.framework.daemon.subscriber extends wiz.framework.daemon.zmqclient
	constructor: (@parent, @binding) -> #{{{
		super 'sub', @binding
	#}}}

	init: () => #{{{
		super()
		@sock.subscribe ""
	#}}}

class wiz.framework.daemon.message
	constructor: (rawmsg) -> #{{{
		if rawmsg
			try
				@datum = JSON.parse(rawmsg.toString())
			catch e
				wiz.log.err "error parsing msg #{rawmsg}"
				return
		else
			@datum =
				ts: (new Date()).getTime()
				from: os.hostname()
	#}}}
	toJSON: () => #{{{
		return JSON.stringify(@datum)
	#}}}

# vim: foldmethod=marker wrap
