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

require '..'

wizpackage 'wiz.framework.backend'

# zero message queue
zmq = require 'zmq'

class wiz.framework.backend.zmqsock
	binding : 'tcp://*:0'
	type : ''

	constructor : (@type, @binding) ->
		@sock = zmq.socket(@type)
	init : () =>
		@sock.on 'message', @onRawMessage
	onRawMessage : (rawmsg) =>
		msg = new wiz.framework.backend.message(rawmsg)
		if not msg or not msg.datum or not msg.datum.ts or not msg.datum.cmd
			wizlog.err @constructor.name, "RECV MSG ERROR: #{rawmsg}"
			@sendERR()
			return
		if msg.datum.cmd == 'ERR' # avoid infinite loop by flagging socket error
			@err = true
		@onMessage(msg)
	onMessage: (msg) =>
		wizlog.debug @constructor.name, "RECV MSG TS#{msg.datum.ts}: #{msg.datum.cmd}"
		# console.log msg
	sendERR: () =>
		return if @err # only send error msg once to avoid infinite loop
		@err = true
		err = new wiz.framework.backend.message()
		err.datum.cmd = 'ERR'
		@send(err)
	sendOK: () =>
		ok = new wiz.framework.backend.message()
		ok.datum.cmd = 'OK'
		@send(ok)
	send : (msg) =>
		if not msg
			msg = 'OK'
		if msg.datum
			wizlog.debug @constructor.name, "SEND MSG TS#{msg.datum.ts}: #{msg.datum.cmd}"
			@sock.send(msg.toJSON())
		else
			wizlog.debug @constructor.name, "SEND MSG RAW: #{msg}"
			@sock.send(msg)

class wiz.framework.backend.zmqserver extends wiz.framework.backend.zmqsock
	init : () =>
		super()
		wizlog.info @constructor.name, "binding to #{@binding}"
		@sock.bind @binding, (err) =>
			if err
				wizlog.crit @constructor.name, "cannot bind socket to #{@binding}: #{err}"
				process.exit()
			# wizlog.info @constructor.name, "bound to #{@binding}"

class wiz.framework.backend.zmqclient extends wiz.framework.backend.zmqsock
	init : () =>
		super()
		@sock.connect @binding

class wiz.framework.backend.responder extends wiz.framework.backend.zmqserver
	constructor : (@parent, @binding) ->
		super('rep', @binding)
class wiz.framework.backend.requester extends wiz.framework.backend.zmqclient
	constructor : (@parent, @binding) ->
		super('req', @binding)

class wiz.framework.backend.publisher extends wiz.framework.backend.zmqserver
	constructor : (@parent, @binding) ->
		super('pub', @binding)
class wiz.framework.backend.subscriber extends wiz.framework.backend.zmqclient
	constructor : (@parent, @binding) ->
		super('sub', @binding)
	init : () =>
		super()
		@sock.subscribe("")

class wiz.framework.backend.message
	constructor: (rawmsg) ->
		if rawmsg
			try
				@datum = JSON.parse(rawmsg.toString())
			catch e
				wizlog.err @constructor.name, "error parsing msg #{rawmsg}"
				return
		else
			@datum = {}
			@datum.ts = (new Date()).getTime()

	toJSON: () =>
		return JSON.stringify(@datum)

# vim: foldmethod=marker wrap
