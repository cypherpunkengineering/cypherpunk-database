# copyright 2013 J. Maurice <j@wiz.biz>

require '../..'
require '../../util/strval'
require '../middleware'

wiz.package 'wiz.framework.http.resource'

class wiz.framework.http.resource.middleware extends wiz.framework.http.middleware.base
	@parseBody: (req, res, cb) => #{{{
		# initialize as empty
		req.body = {}

		# dont bother trying to parse for GET/HEAD
		return cb() if req.method == 'GET'
		return cb() if req.method == 'HEAD'

		# call appropriate parser based on ct
		@parseBodyByCT(req, res, cb)
	#}}}
	@checkAccess: (req, res, cb) => #{{{
		return cb() if req.route.isAccessible(req)
		return req.route.handler403(req, res)
	#}}}

	# arrays must come last to reference methods after they are defined

	@minimum: [ # only used internally
		@parseIP
		@parseHostHeader
		@parseURL
	]

	@base: @minimum.concat [ # resources should use this
		@parseCookie
		@parseBody
	]

# vim: foldmethod=marker wrap
