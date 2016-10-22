# copyright J. Maurice <j@wiz.biz>

wiz.package 'cypherpunk.backend.admin.userjs.accountOverview'

class cypherpunk.backend.admin.userjs.accountOverview extends wiz.framework.app.base
	init: () =>
		@container.append(
			$('<h1>hello</h1>')
		)

$(document).ready =>
	myacct = new cypherpunk.backend.admin.userjs.accountOverview()
	myacct.init()

# vim: foldmethod=marker wrap
