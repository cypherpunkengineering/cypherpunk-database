require './_framework'

wiz.package 'cypherpunk.backend.public'

require './template'

class cypherpunk.backend.public.root extends cypherpunk.backend.template
	level: cypherpunk.backend.server.power.level.stranger
	mask: cypherpunk.backend.server.power.mask.public
	nav: false

	init: () => #{{{
		super()
#		@file = wiz.rootpath + @parent.jade('buy.jade')
#		@args.wizCSS.push @parent.css('buy.css')
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

# vim: foldmethod=marker wrap
