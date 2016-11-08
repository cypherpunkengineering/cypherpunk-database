# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../resource/base'

wiz.package 'wiz.framework.http.account.otpkeys.module'

OTPID = '01960755'

class wiz.framework.http.account.otpkeys.base extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.friend
	mask: wiz.framework.http.resource.power.mask.auth
	middleware: wiz.framework.http.account.session.base

class wiz.framework.http.account.otpkeys.list extends wiz.framework.http.account.otpkeys.base
	handler: (req, res) =>
		req.server.root.accountDB.otpkeys.list(req, res, req.session.account, OTPID)

class wiz.framework.http.account.otpkeys.insert extends wiz.framework.http.account.otpkeys.base
	handler: (req, res) =>
		req.server.root.accountDB.otpkeys.insert(req, res, req.session.account, OTPID)

class wiz.framework.http.account.otpkeys.modify extends wiz.framework.http.account.otpkeys.base
	handler: (req, res) =>
		req.server.root.accountDB.otpkeys.modify(req, res, req.session.account, OTPID)

class wiz.framework.http.account.otpkeys.drop extends wiz.framework.http.account.otpkeys.base
	handler: (req, res) =>
		req.server.root.accountDB.otpkeys.drop(req, res, req.session.account, OTPID)

class wiz.framework.http.account.otpkeys.status extends wiz.framework.http.account.otpkeys.base
	handler: (req, res) =>
		req.server.root.accountDB.otpkeys.otpStatus(req, res, req.session.account, OTPID)

class wiz.framework.http.account.otpkeys.enable extends wiz.framework.http.account.otpkeys.base
	handler: (req, res) =>
		req.server.root.accountDB.otpkeys.otpEnable(req, res, req.session.account, OTPID)

class wiz.framework.http.account.otpkeys.disable extends wiz.framework.http.account.otpkeys.base
	handler: (req, res) =>
		req.server.root.accountDB.otpkeys.otpDisable(req, res, req.session.account, OTPID)

class wiz.framework.http.account.otpkeys.generate extends wiz.framework.http.account.otpkeys.base
	handler: (req, res) =>
		req.server.root.accountDB.otpkeys.otpGenerate(req, res, req.session.account, OTPID)

class wiz.framework.http.account.otpkeys.module extends wiz.framework.http.account.otpkeys.base
	load: () =>
		@routeAdd new wiz.framework.http.account.otpkeys.list(@server, this, 'list', 'GET')
		@routeAdd new wiz.framework.http.account.otpkeys.insert(@server, this, 'insert', 'POST')
		@routeAdd new wiz.framework.http.account.otpkeys.modify(@server, this, 'modify', 'POST')
		@routeAdd new wiz.framework.http.account.otpkeys.drop(@server, this, 'drop', 'POST')
		@routeAdd new wiz.framework.http.account.otpkeys.status(@server, this, 'status', 'GET')
		@routeAdd new wiz.framework.http.account.otpkeys.enable(@server, this, 'enable', 'POST')
		@routeAdd new wiz.framework.http.account.otpkeys.disable(@server, this, 'disable', 'POST')
		@routeAdd new wiz.framework.http.account.otpkeys.generate(@server, this, 'generate', 'POST')

# vim: foldmethod=marker wrap
