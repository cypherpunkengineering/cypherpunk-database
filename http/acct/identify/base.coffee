# copyright 2013 J. Maurice <j@wiz.biz>

require '../../..'
require '../../resource/base'
require '../session'

wiz.package 'wiz.framework.http.acct.identify.base'

class wiz.framework.http.acct.identify.base extends wiz.framework.http.resource.base
	level: wiz.framework.http.resource.power.level.stranger
	mask: wiz.framework.http.resource.power.mask.always

	onIdentifySuccess: (req, res, acct) => #{{{
		# start a new session for the identified user
		wiz.framework.http.acct.session.start(req, res)
		req.session.acct = acct

		# create unauthenticated session object
		req.session.powerLevel = 0
		req.session.auth = 0

		# send 200 OK
		res.send 200
	#}}}

# vim: foldmethod=marker wrap
