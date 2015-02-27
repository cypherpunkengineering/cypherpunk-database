# copyright 2013 J. Maurice <j@wiz.biz>

require '..'
require './asn'

wiz.package 'wiz.framework.x509'

class wiz.framework.x509.certificate extends wiz.framework.crypto.asn.root

	@title: 'CERTIFICATE'

# vim: foldmethod=marker wrap
