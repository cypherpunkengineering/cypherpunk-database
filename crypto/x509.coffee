# copyright 2013 wiz technologies inc.

require '..'
require './asn'
require '../util/list'

wiz.package 'wiz.framework.x509'

class wiz.framework.x509.certificate extends wiz.framework.asn.root

	constructor: () -> #{{{
		super()
	#}}}

	stripHeaderFooter: (stringValue) => #{{{
		stringValue = stringValue.replace("-----BEGIN CERTIFICATE-----", "")
		stringValue = stringValue.replace("-----END CERTIFICATE-----", "")
		stringValue = stringValue.replace(/[\s\n]+/g, "")
		return stringValue
	#}}}

# vim: foldmethod=marker wrap
