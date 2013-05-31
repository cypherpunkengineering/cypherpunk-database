require '..'
require '../wizrsa'
require '../util/list'

wiz.package 'wiz.framework.wizrsa.parser'

class wiz.framework.wizrsa.parser.publicKey extends wiz.framework.list.tree

class wiz.framework.wizrsa.parser.sequence extends wiz.framework.list.tree
	type: wiz.framework.wizrsa.TAG_SEQUENCE

class wiz.framework.wizrsa.parser.bitstring extends wiz.framework.list.tree
	type: wiz.framework.wizrsa.TAG_BITSTRING

class wiz.framework.wizrsa.parser.integer extends wiz.framework.list.tree
	type: wiz.framework.wizrsa.TAG_INTEGER

class wiz.framework.wizrsa.parser.oid extends wiz.framework.list.tree
	type: wiz.framework.wizrsa.TAG_OID

class wiz.framework.wizrsa.parser.nullobj extends wiz.framework.list.tree
	type: null

key = new wiz.framework.wizrsa.parser.publicKey()

s1 = key.push(new wiz.framework.wizrsa.parser.sequence())

s2 = s1.push(new wiz.framework.wizrsa.parser.sequence())
oid1 = s2.push(new wiz.framework.wizrsa.parser.oid())
null1 = s2.push(new wiz.framework.wizrsa.parser.nullobj())

bs1 = s1.push(new wiz.framework.wizrsa.parser.bitstring())
s3 = bs1.push(new wiz.framework.wizrsa.parser.sequence())
i1 = s3.push(new wiz.framework.wizrsa.parser.integer())
i2 = s3.push(new wiz.framework.wizrsa.parser.integer())

oid1.value = 'foo'
null1.value = null
i1.value = 2048
i2.value = 65537

key.each (o) =>
	console.log o.type
