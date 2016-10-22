# copyright 2013 J. Maurice <j@wiz.biz>

require './_framework'
require './_framework/http/resource/base'
require './_framework/http/acct/session'
require './_framework/http/db/mongo'
require './_framework/util/world'

wiz.package 'cypherpunk.backend.api.subscription'

class cypherpunk.backend.api.subscription.resource extends cypherpunk.backend.api.base
	database: null

	init: () =>
		#@database = new cypherpunk.backend.db.subscription(@server, this, @parent.wizDB)
		# api methods
		@routeAdd new cypherpunk.backend.api.subscription.status(@server, this, 'status')
		@routeAdd new cypherpunk.backend.api.subscription.purchase(@server, this, 'purchase', 'POST')
		super()

class cypherpunk.backend.api.subscription.status extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.customer
	mask: cypherpunk.backend.server.power.mask.auth
	middleware: wiz.framework.http.acct.session.base
	handler: (req, res) =>

		start = new Date()
		expiration = new Date(+start)
		expiration.setDate(start.getDate() + 100)

		out =
			type: 'premium'
			renewal: 'monthly'
			expiration: wiz.framework.util.datetime.unixTS(expiration)

		#console.log out
		res.send 200, out

class cypherpunk.backend.api.subscription.purchase extends cypherpunk.backend.api.base
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	handlerOPTIONS: (req, res) => #{{{
		res.setHeader 'Access-Control-Allow-Origin', '*'
		res.setHeader 'Access-Control-Allow-Methods', 'POST,OPTIONS'
		res.setHeader 'Access-Control-Allow-Headers', 'Content-type, Cookie'
		super(req, res)
	#}}}

	handler: (req, res) => #{{{
		return res.send 400, 'missing parameters' unless (req.body?.token? and req.body?.plan? and req.body?.email?)
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.token is 'string'
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.plan is 'string'
		return res.send 400, 'missing or invalid parameters' unless typeof req.body.email is 'string'
		return res.send 400, 'missing or invalid email' unless wiz.framework.util.strval.email_valid(req.body.email)

		args =
			source: req.body.token
			plan: req.body.plan
			email: req.body.email

		console.log args
		try
			@server.root.Stripe.customers.create args, (err, customer) =>
				console.log err
				return res.send 500, err if err
				console.log customer
				return res.send 200, 'ok!!'
		catch e
			console.log e
			res.send 500
	#}}}

# vim: foldmethod=marker wrap
