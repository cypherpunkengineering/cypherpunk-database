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

ain2 = require 'ain2'

class wizlog

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
			tag: global.appname
			facility: 'local0'

	addprio : (prio) =>
		this[prio] = (tag, msg) =>
			@msg(tag, prio, msg)

	ts: () =>
		return new Date().toISOString()

	msg: (tag, priority, msg) =>
		try
			stack = new Error().stack
			.replace(/^\s+at\s+/gm, '')
			.replace(/^Object.<anonymous>\s*\(/gm, '{anonymous}()@')
			.split('\n')
			facility = stack[@stacklevel].split(' ')[0]
		catch e
			facility = tag

		prionum = @priorities[priority]
		if typeof msg == 'string' and msg.length > 0
			while msg[msg.length - 1].charCodeAt(0) == 10
				msg = msg.slice(0, msg.length - 1)

		if priority == 'warning' then priority = 'warn'
		if priority == 'debug' then priority = 'info'
		if priority == 'err' then priority = 'error'
		console[priority] @ts() + " #{priority.toUpperCase()} #{facility}: #{msg}"
		@syslog[priority] msg if @syslog[priority]

module.exports = new wizlog()

# vim: foldmethod=marker wrap
