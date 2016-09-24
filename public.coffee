require './_framework'

wiz.package 'cypherpunk.backend.public'

require './template'

class cypherpunk.backend.public.root extends cypherpunk.backend.template
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	init: () => #{{{
		super()
		@file = wiz.rootpath + @parent.jade('buy.jade')
		@args.wizCSS.push @parent.css('buy.css')
		@args.wizTitle = 'cypherpunk'
	#}}}

class cypherpunk.backend.public.buy extends cypherpunk.backend.template
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	init: () => #{{{
		super()
		@args.wizTitle = 'cypherpunk: plans'
		#@args.wizCSS.push @args.wizCSSfa
		#@args.wizCSS.push @parent.css('stripecard.css')
		#@args.wizJS.push @parent.coffee('accountOverview')
		@file = wiz.rootpath + @parent.jade('card.jade')
		@args.wizJS.push 'https://js.stripe.com/v2/'
		@args.wizJS.push @server.root.js('jquery.card.js')
		@args.wizJS.push @server.root.js('jquery.validate.js')
		@args.wizJS.push @parent.coffee('card')
	#}}}

class cypherpunk.backend.public.subscribe extends cypherpunk.backend.template
#	level: cypherpunk.backend.server.power.level.friend
#	mask: cypherpunk.backend.server.power.mask.auth
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
#	middleware: wiz.framework.http.acct.session.base
	nav: false

	init: () => #{{{
		@method = 'POST'
		super()
	#}}}

	handler: (req, res) => #{{{
		args =
			source: req.body.stripeToken
			plan: "monthly"
			email: "foo@foo.com"
		console.log args
		@parent.Stripe.customers.create args, (err, customer) =>
			console.log err
			return res.send 500, err if err
			console.log customer
			return res.send 200, 'ok!!'
	#}}}

# vim: foldmethod=marker wrap
