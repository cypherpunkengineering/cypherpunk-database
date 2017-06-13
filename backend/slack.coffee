require './_framework'
require './_framework/thirdparty/slack'

wiz.package 'cypherpunk.backend.slack'

class cypherpunk.backend.slack extends wiz.framework.thirdparty.slack
	webhook: "/services/T0RBA0BAP/B5STLD6ET/Afu3o00tc0LIHLbTpUucvZuG"

	notify: (text, cb) => #{{{
		if wiz.style is 'DEV'
			text = "[*TEST*] #{text}"
		else
			text = "[*LIVE*] #{text}"
		super(text, cb)
	#}}}

# vim: foldmethod=marker wrap
