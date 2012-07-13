# wiz-framework
require '..'

# wizbackend package
wizpackage 'wizbackend'

# zero message queue
zmq = require 'zmq'

# listen on a zmq socket
class wizbackend.listener

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

class wizbackend.publisher

	sock : 'tcp://*:0'

	constructor : () ->
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

	constructor : () ->
		@subscriber = zmq.socket('sub')

	init : () =>
		@subscriber.on 'message', @onMessage
		@subscriber.connect(@sock)
		@subscriber.subscribe("")

	onMessage : (msg) =>
		wizlog.debug @constructor.name, "onMessage: #{msg}"
