# copyright 2013 wiz technologies inc.

require '..'
require '../util/list'

BigInteger = require './jsbn'
SecureRandom = require './rng'

wiz.package 'wiz.framework.crypto.asn'

class wiz.framework.crypto.asn.node extends wiz.framework.list.tree

	constructor: (@scope, @type, @inBuffer) -> #{{{
		if @scope.id == wiz.framework.crypto.asn.node.scopesByName.CONTEXT.id
			@type.container = true
		super()
	#}}}

	class scope #{{{
		constructor: (@id, @description) ->
	#}}}
	@scopesByBits: #{{{
		0b00000000:	new scope(0b00000000, "UNIVERSAL")
		0b01000000:	new scope(0b01000000, "APPLICATION")
		0b10000000:	new scope(0b10000000, "CONTEXT")
		0b11000000:	new scope(0b11000000, "PRIVATE")
	#}}}
	@scopesByName: #{{{
		UNIVERSAL:		@scopesByBits[0b00000000]
		APPLICATION:	@scopesByBits[0b01000000]
		CONTEXT:		@scopesByBits[0b10000000]
		PRIVATE:		@scopesByBits[0b11000000]
	#}}}

	class nodeType #{{{
		constructor: (@id, @description, @printable = false, @container = false) ->
	#}}}
	@typesByID: #{{{

		0x00: new nodeType(0x00, 'basic encoding rule header')
		0x01: new nodeType(0x01, 'boolean')
		0x02: new nodeType(0x02, 'integer')
		0x03: new nodeType(0x03, 'bit string', false, true)
		0x04: new nodeType(0x04, 'octet string', false, true)
		0x05: new nodeType(0x05, 'null')
		0x06: new nodeType(0x06, 'object identifier', true)
		0x07: new nodeType(0x07, 'ObjectDescriptor')
		0x08: new nodeType(0x08, 'instance of/external')
		0x09: new nodeType(0x09, 'real')
		0x0A: new nodeType(0x0A, 'enumerated')
		0x0B: new nodeType(0x0B, 'pdv')
		0x0C: new nodeType(0x0C, 'utf8string', true)
		0x0D: new nodeType(0x0D, 'relative-oid')
		0x10: new nodeType(0x10, 'sequence', false, true)
		0x11: new nodeType(0x11, 'set, set of', false, true)
		0x12: new nodeType(0x12, 'numeric string', true)
		0x13: new nodeType(0x13, 'printable string', true)
		0x14: new nodeType(0x14, 'teletex string')
		0x15: new nodeType(0x15, 'videotex string')
		0x16: new nodeType(0x16, 'ia5string')
		0x17: new nodeType(0x17, 'utctime', true)
		0x18: new nodeType(0x18, 'GeneralizedTime', true)
		0x19: new nodeType(0x19, 'GraphicString', true)
		0x1A: new nodeType(0x1A, 'VisibleString, ISO64String')
		0x1B: new nodeType(0x1B, 'GeneralString', true)
		0x1C: new nodeType(0x1C, 'UniversalString', true)
		0x1D: new nodeType(0x1D, 'character string', true)
		0x1E: new nodeType(0x1E, 'BMPString', true)
	#}}}
	@typesByName: #{{{

		BER:			@typesByID[0x00]
		BOOL:			@typesByID[0x01]
		INTEGER:		@typesByID[0x02]
		BITSTRING:		@typesByID[0x03]
		OCTET:			@typesByID[0x04]
		NULLOBJ:		@typesByID[0x05]
		OID:			@typesByID[0x06]
		OD:				@typesByID[0x07]
		INSTOF:			@typesByID[0x08]
		REAL:			@typesByID[0x09]
		ENUM:			@typesByID[0x0A]
		EPDV:			@typesByID[0x0B]
		UTF8STRING:		@typesByID[0x0C]
		RELATIVEOLD:	@typesByID[0x0D]
		SEQUENCE:		@typesByID[0x10]
		SETOF:			@typesByID[0x11]
		NUMERIC:		@typesByID[0x12]
		PRINTABLE:		@typesByID[0x13]
		TELETEX:		@typesByID[0x14]
		VIDEOTEX:		@typesByID[0x15]
		IA5:			@typesByID[0x16]
		UTCTIME:		@typesByID[0x17]
		GENTIME:		@typesByID[0x18]
		GRAPHIC:		@typesByID[0x19]
		VISIBLE:		@typesByID[0x1A]
		GENERAL:		@typesByID[0x1B]
		UNIVERSAL:		@typesByID[0x1C]
		CHARACTER:		@typesByID[0x1D]
		BMP:			@typesByID[0x1E]
	#}}}

	@fromType: (type) => #{{{
		return new wiz.framework.crypto.asn.node(wiz.framework.crypto.asn.node.scopesByName.UNIVERSAL, wiz.framework.crypto.asn.node.typesByName[type])
	#}}}
	@fromBuffer: (inBuffer) => #{{{ parses a single asn node from given slice of buffer

		# get id of root node
		idBuffer = wiz.framework.crypto.asn.node.getASNid(inBuffer)
		idInt = idBuffer.readUInt8(0)
		id = idInt & 0b00011111
		scopeInt = idInt & 0b11000000
		scope = @scopesByBits[scopeInt]
		switch scope.description
			when "UNIVERSAL"
				type = @typesByID[id]
			else
				type = new node(id, "[#{id}]")

		if not type?
			wiz.log.err 'invalid asn id value: '+ id
			return null

		n = new wiz.framework.crypto.asn.node(scope, type, inBuffer)
		return n
	#}}}

	setValue: (inValue) => #{{{
		if @type.id is wiz.framework.crypto.asn.node.typesByName.OID.id && @scope.id is wiz.framework.crypto.asn.node.scopesByName.UNIVERSAL.id
			oidString = inValue.toString('utf8')
			oidNodeArray = oidString.split('.')
			oidEncoded = ''
			oidNodeInt = 0
			for oidNode,n in oidNodeArray
				oidNodeInt = parseInt(oidNode)
				if n == 0
					oidEncoded = parseInt(oidNode * 40)
				else if n == 1
					oidEncoded += parseInt(oidNode)
					oidEncoded = oidEncoded.toString(16)
					oidEncoded = wiz.framework.crypto.asn.root.doPaddingOnHexstring(oidEncoded)
				else if oidNodeInt < 128
					hexString = oidNodeInt.toString(16)
					hexString = wiz.framework.crypto.asn.root.doPaddingOnHexstring(hexString)
					oidEncoded = oidEncoded + hexString
				else
					byteArray = []
					i = 0
					while oidNodeInt > 0
						if i == 0
							byteArray[i] = oidNodeInt & 0x7F
						else
							byteArray[i] = (oidNodeInt & 0x7F) | 0x80
						oidNodeInt = oidNodeInt >> 7
						i++

					while i >= 0
						oidNodeEncoded = oidNodeEncoded << 8
						oidNodeEncoded = oidNodeEncoded | byteArray[i]
						i--
					hexString = oidNodeEncoded.toString(16)
					hexString = wiz.framework.crypto.asn.root.doPaddingOnHexstring(hexString)
					oidEncoded = oidEncoded + hexString
			@value = new Buffer(oidEncoded.toString(16), 'hex')
		else
			@value = inValue
	#}}}

	@getASNid: (inBuffer) => #{{{
		idByte = inBuffer.slice(0,1)
		return idByte
	#}}}
	getASNsizeBufferLength: () => #{{{
		# Size buffer length should always be 1 byte
		lengthByte = @inBuffer.slice(1,2).readUInt8(0)
		if lengthByte < 128
			# Return -1 if we don't need to advance position when reading sizebufferlength
			return -1
		sizeBufLength = lengthByte - 0x80
		return sizeBufLength
	#}}}
	getASNvalueSize: () => #{{{
		sizeBufferLength = @getASNsizeBufferLength()
		if sizeBufferLength == -1
			sizeBuf = @inBuffer.slice(1,2)
		else
			sizeBuf = @inBuffer.slice(2, 2+sizeBufferLength)
		size = parseInt(sizeBuf.toString('hex'), 16)
		return size
	#}}}
	getValueBuffer: () => #{{{
		startPtr = 2
		sizeBufSize = @getASNsizeBufferLength()
		valueSize = @getASNvalueSize()

		if sizeBufSize == -1
			value = @inBuffer.slice(startPtr, startPtr + valueSize)
		else
			value = @inBuffer.slice(startPtr + sizeBufSize, startPtr + sizeBufSize + valueSize)

		# strip off trailing bits for bitstring
		if @type.id == wiz.framework.crypto.asn.node.typesByName.BITSTRING.id and value.readUInt8(0) == 0
			# TODO: properly parse trailing bits if != 0
			value = value.slice(1, value.length)

		return value
	#}}}
	getNodeSize: () => #{{{
		size = @getASNsizeBufferLength()
		if size < 0
			size = 1
		else
			size++
		size += @getASNvalueSize() + 1
		return size
	#}}}

	toString: () => #{{{
		value = @getValueBuffer()
		if value?
			if @type.id is wiz.framework.crypto.asn.node.typesByName.OID.id && @scope.id is wiz.framework.crypto.asn.node.scopesByName.UNIVERSAL.id
				firstTwoNodes = value.readUInt8(0)
				firstNode = Math.floor(firstTwoNodes / 40)
				secondNode = firstTwoNodes % 40
				oidString = "#{firstNode}.#{secondNode}"
				oidNode = 0
				for i in [1..value.length-1]
					oidNode = oidNode << 7
					currentByte = value.slice(i,i+1)
					cb = currentByte.readUInt8(0) & 0x7F
					oidNode = oidNode | cb
					if (currentByte.readUInt8(0) < 128)
						oidString += ".#{oidNode}"
						oidNode = 0
				return oidString
			else
				return value.toString('utf8')
	#}}}
	generateTag: () => #{{{
		combined = (@scope.id | @type.id)

		if @type.id == wiz.framework.crypto.asn.node.typesByName.SEQUENCE.id
			combined = (combined | 0b00100000)

		tag = wiz.framework.crypto.asn.root.doPaddingOnHexstring(combined.toString(16))

		return new Buffer(tag, 'hex')
	#}}}
	encodeASN: () => #{{{
		@encodeContainer() if @type.container
		result = @generateTag()
		valueBuffer = (if @value? then @value else @getValueBuffer())

		if @type.id == wiz.framework.crypto.asn.node.typesByName.NULLOBJ.id
			return Buffer.concat([result, new Buffer('00', 'hex')])

		if @type.id == wiz.framework.crypto.asn.node.typesByName.BITSTRING.id
			valueBuffer = Buffer.concat([new Buffer('00', 'hex'), valueBuffer])

		size = 0
		size = valueBuffer.length if valueBuffer

		# Calculate how many bytes are needed to store the value of size
		if size < 127 #& 0b10000000 == 0b00000000
			sizehex = new Buffer("0" + size.toString(16), 'hex')
			result = Buffer.concat([result, sizehex])
		else
			hexstring = size.toString(16)

			# pads the hexstring to always have even number of bytes
			hexstring = "0" + hexstring if hexstring.length % 2 is 1

			# create new buffer
			sizeBuf = new Buffer(hexstring, 'hex')
			# 0x80 + (2 or 3)
			firstByte = 0x80 + sizeBuf.length
			fb = new Buffer(firstByte.toString(16), 'hex')
			result = Buffer.concat([result, fb, sizeBuf])

		result = Buffer.concat([result, valueBuffer])
		return result
	#}}}
	encodeContainer: () => #{{{
		v = new Buffer(0)
		#x = @each (f) =>
		n = @branchList.tail
		while n
			v = Buffer.concat([v,n.encodeASN()])
			n = n.prev
		@value = v
	#}}}

class wiz.framework.crypto.asn.root extends wiz.framework.list.tree

	@doPaddingOnHexstring: (hexstring) => #{{{
		if hexstring.length % 2 == 1
			hexstring = "0" + hexstring
		return hexstring
	#}}}

	parseBuffer: (inBuffer, currentBranch, position = 0) => #{{{ recursive method to parse containers
		while (position < inBuffer.length)
			slice = inBuffer.slice(position)
			newBranch = currentBranch.branchAdd(wiz.framework.crypto.asn.node.fromBuffer(slice))
			#wiz.log.debug "decription is #{newBranch.type.description}"
			if newBranch.type.container
				@parseBuffer(newBranch.getValueBuffer(), newBranch, 0)
			position += newBranch.getNodeSize()
	#}}}
	printTree: () => #{{{
		@tailEach 0, (d, n) =>
			indent = ''
			for i in [0..d]
				continue if i is 0
				indent += '|  '
			str = indent
			str += n.type.description + ' '
			str += n.toString() if n.type.printable or n.scope.id isnt wiz.framework.crypto.asn.node.scopesByName.UNIVERSAL.id
			console.log str
	#}}}
	@linebrk: (buf, n) -> #{{{
		s = buf.toString("ascii")
		ret = ""
		i = 0
		while i + n < s.length
			ret += s.substring(i, i + n) + "\n"
			i += n
		ret + s.substring(i, s.length)
	#}}}
	encodeASN: () => #{{{
		v = new Buffer(0)
		n = @branchList.tail
		while n
			v = Buffer.concat([v,n.encodeASN()])
			n = n.prev
		return v
	#}}}

	setValuesFromTree: () => #{{{
	#}}}

# vim: foldmethod=marker wrap
