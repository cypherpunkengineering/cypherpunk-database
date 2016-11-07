# wizportal web interface
# copyright J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/resource/power'
require './_framework/http/resource/jade'
require './_framework/http/resource/coffee-script'
require './_framework/http/account'
require './_framework/http/account/session'

require './power'

wiz.package 'cypherpunk.backend.base'

class cypherpunk.backend.base extends wiz.framework.http.resource.base
	level: cypherpunk.backend.server.power.level.admin
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.base
	handler: (req, res) =>
		wiz.log.debug "Default handler redirect to root page for #{req.url}"
		@redirect(req, res, '/')

wiz.package 'cypherpunk.backend.jadeTemplate'

class cypherpunk.backend.jadeTemplate extends wiz.framework.http.resource.jadeTemplate
	level: cypherpunk.backend.server.power.level.admin
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.account.session.base.concat [
	]
	handler403: (req, res) =>
		wiz.log.debug "Redirect to login page for #{req.url}"
		redirectTo = '/login?for=' + req.url
		@redirect(req, res, redirectTo)

wiz.package 'cypherpunk.backend.template'

class cypherpunk.backend.template extends cypherpunk.backend.jadeTemplate
	render: (req, res) =>
		@args.wizNav = req?.nav || {}
		super req, res

	init: () =>
		@file ?= wiz.rootpath + @parent.jade('wiz.jade')

		@args.wizMethodLevel ?= @level
		@args.wizMethodPublic ?= (@mask == wiz.framework.http.resource.power.mask.public || @mask == wiz.framework.http.resource.power.mask.always)

		@args.wizBody ?= ''
		@args.wizBodies ?= 1

		@args.wizCSSP ?= []
		@args.wizCSS ?= [
			@server.root.css('bootstrap.css')
			@server.root.css('wiz.css')
		]

		@args.wizCSSdt ?= [
			@server.root.css('jquery.dataTables.css')
			@server.root.css('dataTables.bootstrap.css')
			@server.root.css('table.css')
		]

		@args.wizCSSfa ?=
		[
			@server.root.css('font-awesome.min.css')
		]

		@args.wizJS ?= [
			@server.root.js('jquery-2.1.3.min.js')
			@server.root.js('bootstrap.min.js')
			@server.root.coffee('wiz')
			@server.root.coffee('base')
			@server.root.coffee('session')
			@server.root.coffee('sessionManager')
		]

		@args.wizJSdt ?= [
			@server.root.js('jquery.dataTables.min.js')
			@server.root.js('jquery.dataTables.bootstrap-pagination.js')
			@server.root.js('dataTables.bootstrap.js')
			@server.root.coffee('table')
			@server.root.coffee('strval')
		]

		@args.wizJSdtMulti ?= @args.wizJSdt.concat [
			@server.root.coffee('tableMulti')
		]

		@args.wizJSdtMultiMulti ?= @args.wizJSdtMulti.concat [
			@server.root.coffee('tableMultiMulti')
		]

		@args.wizNav ?= []
		@args.wizLevel ?= []

## TODO: move below stuff into AJAX query
#
#		user =
#			auth: false
#			otp: {}
#
#		user.auth = true if req.session?.wiz?.auth
#
#		if req.session.wiz.user
#			user.id = req.session.wiz.user.id
#			user.email = req.session.wiz.user.email
#			user.level = req.session.wiz.user.level
#			if req.session.wiz.user.otp
#				user.otp.require = req.session.wiz.user.otp.require
#
#		page.wizDumpJS.push { name: 'window.wiz.user', data: user }

## TODO: move above stuff into AJAX query

		super()

# vim: foldmethod=marker wrap
