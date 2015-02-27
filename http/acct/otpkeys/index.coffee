# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../resource/base'

wiz.package 'wiz.framework.http.acct.otpkeys.module'

OTPID = '01960755'

class wiz.framework.http.acct.otpkeys.base extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.friend
	mask: wiz.framework.http.resource.power.mask.auth
	middleware: wiz.framework.http.acct.session.base

class wiz.framework.http.acct.otpkeys.list extends wiz.framework.http.acct.otpkeys.base
	handler: (req, res) =>
		@parent.parent.db.otpkeys.list(req, res, req.session.acct, OTPID)

class wiz.framework.http.acct.otpkeys.insert extends wiz.framework.http.acct.otpkeys.base
	handler: (req, res) =>
		@parent.parent.db.otpkeys.insert(req, res, req.session.acct, OTPID)

class wiz.framework.http.acct.otpkeys.modify extends wiz.framework.http.acct.otpkeys.base
	handler: (req, res) =>
		@parent.parent.db.otpkeys.modify(req, res, req.session.acct, OTPID)

class wiz.framework.http.acct.otpkeys.drop extends wiz.framework.http.acct.otpkeys.base
	handler: (req, res) =>
		@parent.parent.db.otpkeys.drop(req, res, req.session.acct, OTPID)

class wiz.framework.http.acct.otpkeys.status extends wiz.framework.http.acct.otpkeys.base
	handler: (req, res) =>
		@parent.parent.db.otpkeys.otpStatus(req, res, req.session.acct, OTPID)

class wiz.framework.http.acct.otpkeys.enable extends wiz.framework.http.acct.otpkeys.base
	handler: (req, res) =>
		@parent.parent.db.otpkeys.otpEnable(req, res, req.session.acct, OTPID)

class wiz.framework.http.acct.otpkeys.disable extends wiz.framework.http.acct.otpkeys.base
	handler: (req, res) =>
		@parent.parent.db.otpkeys.otpDisable(req, res, req.session.acct, OTPID)

class wiz.framework.http.acct.otpkeys.generate extends wiz.framework.http.acct.otpkeys.base
	handler: (req, res) =>
		@parent.parent.db.otpkeys.otpGenerate(req, res, req.session.acct, OTPID)

class wiz.framework.http.acct.otpkeys.module extends wiz.framework.http.acct.otpkeys.base
	load: () =>
		@routeAdd new wiz.framework.http.acct.otpkeys.list(@server, this, 'list', 'GET')
		@routeAdd new wiz.framework.http.acct.otpkeys.insert(@server, this, 'insert', 'POST')
		@routeAdd new wiz.framework.http.acct.otpkeys.modify(@server, this, 'modify', 'POST')
		@routeAdd new wiz.framework.http.acct.otpkeys.drop(@server, this, 'drop', 'POST')
		@routeAdd new wiz.framework.http.acct.otpkeys.status(@server, this, 'status', 'GET')
		@routeAdd new wiz.framework.http.acct.otpkeys.enable(@server, this, 'enable', 'POST')
		@routeAdd new wiz.framework.http.acct.otpkeys.disable(@server, this, 'disable', 'POST')
		@routeAdd new wiz.framework.http.acct.otpkeys.generate(@server, this, 'generate', 'POST')

# vim: foldmethod=marker wrap
