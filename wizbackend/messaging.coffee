# wiz-framework
require '..'

# wizbackend package
wizpackage 'wizbackend'

# zero message queue
zmq = require 'zmq'

class wizbackend.zmqsock
	binding : 'tcp://*:0'
	type : ''

	constructor : (@type, @binding) ->
		@sock = zmq.socket(@type)
	init : () =>
		@sock.on 'message', @onMessage
	onMessage : (msg) =>
		wizlog.debug @constructor.name, "onMessage: #{msg}"
	send : (msg) =>
		# wizlog.debug @constructor.name, "send: #{msg}"
		@sock.send(msg)

class wizbackend.zmqserver extends wizbackend.zmqsock
	init : () =>
		super()
		wizlog.info @constructor.name, "binding to #{@binding}"
		@sock.bind @binding, (err) =>
			if err
				wizlog.crit @constructor.name, "cannot bind socket to #{@binding}: #{err}"
				process.exit()
			# wizlog.info @constructor.name, "bound to #{@binding}"

class wizbackend.zmqclient extends wizbackend.zmqsock
	init : () =>
		super()
		@sock.connect @binding

class wizbackend.responder extends wizbackend.zmqserver
	constructor : (@parent, @binding) ->
		super('rep', @binding)
class wizbackend.requester extends wizbackend.zmqclient
	constructor : (@parent, @binding) ->
		super('req', @binding)

class wizbackend.publisher extends wizbackend.zmqserver
	constructor : (@parent, @binding) ->
		super('pub', @binding)
class wizbackend.subscriber extends wizbackend.zmqclient
	constructor : (@parent, @binding) ->
		super('sub', @binding)
	init : () =>
		super()
		@sock.subscribe("")

# vim: foldmethod=marker wrap
