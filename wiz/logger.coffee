# copyright 2013 J. Maurice <j@wiz.biz>

dgram = require 'dgram'

wiz.package 'wiz.logger'

class wiz.logger

	priorities: # {{{ from syslog(3)
		emerg:	0 # system is unusable
		alert:	1 # action must be taken immediately
		crit:	2 # critical conditions
		err:	3 # error conditions
		warn:	4 # warning conditions
		notice:	5 # normal but significant condition
		info:	6 # informational
		debug:	7 # debug-level messages
	#}}}
	facilities: #{{{
		kern:	0
		user:	1
		mail:	2
		daemon:	3
		auth:	4
		syslog:	5
		lpr:	6
		news:	7
		uucp:	8
		local0:	16
		local1:	17
		local2:	18
		local3:	19
		local4:	20
		local5:	21
		local6:	22
		local7:	23
	#}}}

	constructor: (@fac = @facilities.local0) -> #{{{
		@loghost = '127.0.0.1'
		@logport = 514

		# add each priority as a method
		for prio of @priorities
			@addprio prio
	#}}}

	addprio: (prio) => #{{{ create a .method for each logging priority
		this[prio] = (msg) =>
			@msg(prio, msg)
	#}}}

	tag: () => #{{{ try to get the method that created the message
		stacklevel = 6
		try
			stack = new Error().stack
			.replace(/^\s+at\s+/gm, '')
			.replace(/^Object.<anonymous>\s*\(/gm, '{anonymous}()@')
			.split('\n')
			tag = stack[stacklevel].split(' ')[0]
		catch e
			tag = ''

		return tag
	#}}}
	msg: (priority, msg) => #{{{ log a message

		# trim newline
		if typeof msg == 'string' and msg.length > 0
			while msg[msg.length - 1].charCodeAt(0) == 10
				msg = msg.slice(0, msg.length - 1)

		# get tag from callstack top frame
		tag = @tag()

		# get priority number
		prionum = @priorities[priority] or @priorities.info

		# build syslog msg
		syslogmsg = ""
		syslogmsg +='<' + (@fac * 8 + prionum) + '>'
		syslogmsg += @ts() + ' '
		syslogmsg += wiz.name || 'wiz'
		syslogmsg += "[#{process.pid}]: "
		syslogmsg += tag + ': ' if tag
		syslogmsg += priority.toUpperCase() + ' ' if priority
		syslogmsg += msg if msg

		# build console message
		consolemsg = ""
		consolemsg += @ts() + ' '
		consolemsg += process.pid + ' '
		consolemsg += priority.toUpperCase() + ' ' if priority
		consolemsg += tag + ': '
		consolemsg += msg if msg

		# send to syslog socket
		@syslog(syslogmsg)

		# map syslog priorities to console.(prio)
		if priority == 'warning' then priority = 'warn'
		if priority == 'debug' then priority = 'info'
		if priority == 'err' then priority = 'error'

		# log on console
		(console[priority] or console.error)(consolemsg)
	#}}}
	syslog: (msg) => #{{{ send logmsg to syslog socket

		msgbuf = new Buffer(msg)

		client = dgram.createSocket "udp4"

		client.send msgbuf, 0, msgbuf.length, @logport, @loghost, (err, bytes) ->
			console.log err if err
			client.close()
	#}}}

	leadZero: (n) -> #{{{
		if n < 10
			return '0' + n
		return n
	#}}}
	ts: () -> #{{{
		dt = new Date()
		hours = @leadZero(dt.getHours())
		minutes = @leadZero(dt.getMinutes())
		seconds = @leadZero(dt.getSeconds())
		month = dt.getMonth()
		day = dt.getDate()
		day = " " + day  if day < 10
		months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
		months[month] + " " + day + " " + hours + ":" + minutes + ":" + seconds
	#}}}

# vim: foldmethod=marker wrap
