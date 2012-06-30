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

class wizlog

	priorities: # from syslog(3)

		emerg:		0 # system is unusable
		alert:		1 # action must be taken immediately
		crit:		2 # critical conditions
		err:		3 # error conditions
		warning:	4 # warning conditions
		notice:		5 # normal but significant condition
		info:		6 # informational
		debug:		7 # debug-level messages

	constructor: () ->
		# add each priority as a method
		for prio of @priorities
			@addprio prio

	addprio : (prio) ->
		this[prio] = (tag, msg) =>
			@msg(tag, prio, msg)

	ts: () ->
		return new Date().toISOString()

	msg: (tag, priority, msg) ->
		ts = @ts()
		facility = pkgname + '.' + tag
		prionum = @priorities[priority]
		if typeof msg == 'string'
			while msg[msg.length - 1].charCodeAt(0) == 10
				msg = msg.slice(0, msg.length - 1)
		console.log "#{ts} #{facility}(#{priority}): #{msg}"
		# TODO: log to system syslog as well

module.exports = new wizlog()

# vim: foldmethod=marker wrap
