# wiz-framework: J's HTML5/NodeJS web application framework
#
# Copyright 2012 J. Maurice <j@wiz.biz>
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of version 3 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

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
