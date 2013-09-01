# wiz-framework: J's HTML5/NodeJS web application framework
#
# Copyright 2012 J. Maurice <j@wiz.biz>
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of version 3 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

require '..'
require './convert'

wiz.package 'wiz.framework.crypto.hash'

BigInteger = require './jsbn'
crypto = require 'crypto'

class wiz.framework.crypto.hash

	# foo = { bar: 1, baz: 2 }
	# digest(foo)
	@digest: (obj, hash = 'sha256', encoding = 'base32') ->

		# use native crypto lib
		shasum = crypto.createHash(hash)

		# convert to string if necessary
		if typeof obj is 'object'
			shasum.update JSON.stringify(obj)
		else
			shasum.update obj

		# custom encodings
		if encoding is 'base32'
			digest = shasum.digest()
			digestBI = new BigInteger(digest)
			return wiz.framework.crypto.convert.biToBase32(digestBI, undefined, 51)
		else
			return shasum.digest(encoding)

# vim: foldmethod=marker wrap
