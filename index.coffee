# top-level wiz object
# copyright 2013 wiz technologies inc.

process.on 'SIGINT', () =>
	process.exit()

class global.wiz
	@hostname: require('os').hostname()
	@rootpath: process.cwd()

	@app: (@name, @style = 'DEV') =>

	@package: (name) ->
		levels = name.split '.'
		space = global
		for ns, i in levels
			# console.log levels[0..i].join('.')
			space[ns] = space[ns] or {}
			space = space[ns]

	@assert: (expr, err) ->
		return if expr
		wiz.log.err "ASSERTION FAIL! #{err}"

require './wiz/logger'
require './wiz/base'

wiz.log = new wiz.logger()

module.exports = wiz

# vim: foldmethod=marker wrap
