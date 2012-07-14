# wiz-framework
require '..'

# wizbackend package
wizpackage 'wizbackend'

# zero message queue
zmq = require 'zmq'

class wizbackend.responder

	sock : 'tcp://*:0'

	constructor : (@parent, @sock) ->
		# allocate a socket for listening
		@responder = zmq.socket('rep')

	init : () =>
		# listen for messages
		@responder.on 'message', @onMessage
		@responder.bind @sock, (err) =>
			if err
				wizlog.crit @constructor.name, "cannot bind to socket #{@sock}: #{err}"
				process.exit()

		wizlog.info @constructor.name, "bound to #{@sock}"

	onMessage : (msg) =>
		wizlog.debug @constructor.name, "onMessage: #{msg}"

	send : (msg) =>
		# wizlog.debug @constructor.name, "send: #{msg}"
		@responder.send(msg)

class wizbackend.requester

	sock : 'tcp://*:0'

	constructor : (@parent, @sock) ->
		# allocate a socket for listening
		@requester = zmq.socket('req')

	init : () =>
		@requester.on 'message', @onMessage
		@requester.connect(@sock)

		wizlog.info @constructor.name, "bound to #{@sock}"

	onMessage : (msg) =>
		wizlog.debug @constructor.name, "onMessage: #{msg}"

	send : (msg) =>
		# wizlog.debug @constructor.name, "send: #{msg}"
		@requester.send(msg)

class wizbackend.publisher

	sock : 'tcp://*:0'

	constructor : (@parent, @sock) ->
		@publisher = zmq.socket('pub')

	init : () =>
		@publisher.bind @sock, (err) =>
			if err
				wizlog.crit @constructor.name, "cannot bind to socket #{@sock}: #{err}"
				process.exit()

	send: (msg) =>
		wizlog.debug @constructor.name, "sendMessage: #{msg}"
		@publisher.send(msg)

class wizbackend.subscriber

	sock : 'tcp://*:0'

	constructor : (@parent, @sock) ->
		@subscriber = zmq.socket('sub')

	init : () =>
		@subscriber.on 'message', @onMessage
		@subscriber.connect(@sock)
		@subscriber.subscribe("")

	onMessage : (msg) =>
		wizlog.debug @constructor.name, "onMessage: #{msg}"
