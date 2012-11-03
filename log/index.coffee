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

wiz.package 'wiz.log'

ain2 = require '../../_deps/ain'

class wiz.logger

	priorities: # from syslog(3)

		# system is unusable
		emerg:		0
		# action must be taken immediately
		alert:		1
		# critical conditions
		critical:	2
		crit:		2
		# error conditions
		err:		3
		error:		3
		# warning conditions
		warn:		4
		warning:	4
		# normal but significant condition
		notice:		5
		# informational
		info:		6
		# debug-level messages
		debug:		7
		trace:		7

	constructor: () ->
		# add each priority as a method
		@stacklevel = 4
		@syslog = null
		for prio of @priorities
			@addprio prio

	init: () =>
		@syslog = new ain2
			tag: wiz.app.name
			facility: 'local0'

	addprio : (prio) =>
		this[prio] = (msg) =>
			@msg(prio, msg)

	ts: () =>
		return new Date().toISOString()

	msg: (priority, msg) =>
		try
			stack = new Error().stack
			.replace(/^\s+at\s+/gm, '')
			.replace(/^Object.<anonymous>\s*\(/gm, '{anonymous}()@')
			.split('\n')
			facility = stack[@stacklevel].split(' ')[0]
		catch e
			facility = 'unknown'

		prionum = @priorities[priority]
		if typeof msg == 'string' and msg.length > 0
			while msg[msg.length - 1].charCodeAt(0) == 10
				msg = msg.slice(0, msg.length - 1)

		if priority == 'warning' then priority = 'warn'
		if priority == 'debug' then priority = 'info'
		if priority == 'err' then priority = 'error'

		logmsg = @ts() + ' '
		logmsg += process.pid + ' '
		logmsg += wiz.app.style + ' ' if wiz.app and wiz.app.style
		logmsg += priority.toUpperCase() + ' ' if priority
		logmsg += facility + ': ' if facility
		logmsg += msg if msg
		(console[priority] or console.error)(logmsg)

		@syslog[priority] msg if @syslog and @syslog[priority]

# vim: foldmethod=marker wrap
