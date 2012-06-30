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
require '../wiz-framework'
require '../wiz-framework/wizfrontend'

# wizportal package
wizpackage 'wizportal'

class wizportal.serverConfig extends wizfrontend.serverConfig
	sessionSecret: '242tbjiv45y8tfbj75edtesxcvg5rghj'

class wizportal.server extends wizfrontend.server

	config: new wizportal.serverConfig()

	pengiPage : (title, req) =>
		page =
			pengiAuth : @middleware.checkAuth(req)
			pengiTitle : title
			pengiHeader : title
			pengiNav : @nav
			pengiGeneratedOn : new Date()
			pengiDescription : ''
			pengiKeywords : ''
			pengiBody : ''
			pengiLeftBox : ''
			pengiRightBox : ''
			pengiMsg : ''
			pengiCopyright : '2012 Pengi K.K.'
			pengiJS : [
				@core.js 'pengi'
			]
		return page

	handleRoot : (req, res) =>
		if req.session.wizfrontendAuth
			@redirect req, res, null, '/home'
			return
		page = @pengiPage 'wizportal', req
		page.pengiJS.push @core.js('jquery.min')
		page.pengiJS.push @core.js('pengi-login')
		res.render 'login', page

	handleHome : (req, res) ->
		page = @pengiPage 'wizportal', req
		page.pengiBody = 'hello world'
		res.render 'pengi', page

portal = new wizportal.server()
#require './module1'
#module1 = new wizportal.module1(portal)
portal.start()

# vim: foldmethod=marker wrap
