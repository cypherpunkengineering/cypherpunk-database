# wiz framework QR code utility classes
# copyright 2013 J. Maurice <j@wiz.biz>
#
# based on "QR Code Generator for JavaScript", copyright 2009 Kazuhiko Arase
# licensed under the MIT license as per website http://www.d-project.com/
# original from http://jeromeetienne.github.io/jquery-qrcode/src/qrcode.js
#

require '..'

wiz.package 'wiz.framework.util.qr'

class wiz.framework.util.qr.EightBitByte #{{{
	constructor: (@data) -> #{{{
		@mode = wiz.framework.util.qr.Mode.MODE_8BIT_BYTE
	#}}}
	getLength: (buffer) => #{{{
		return @data.length
	#}}}
	write: (buffer) => #{{{
		for i in [0...@data.length]
			buffer.put(@data.charCodeAt(i), 8)
	#}}}
#}}}
class wiz.framework.util.qr.Code #{{{
	constructor: (@typeNumber, @errorCorrectLevel) -> #{{{
		@modules = null
		@moduleCount = 0
		@dataCache = null
		@dataList = new Array()
	#}}}
	addData: (data) => #{{{
		newData = new wiz.framework.util.qr.EightBitByte(data)
		@dataList.push(newData)
		@dataCache = null
	#}}}
	isDark: (row, col) => #{{{
		if row < 0 || @moduleCount <= row || col < 0 || @moduleCount <= col
			throw new Error(row + "," + col)

		return @modules[row][col]
	#}}}
	getModuleCount: () => #{{{
		return @moduleCount
	#}}}
	make: () => #{{{
		# Automatically calculate typeNumber if provided is < 1
		if @typeNumber < 1
			typeNumber = 1
			for typeNumber in [1...40]
				rsBlocks = wiz.framework.util.qr.RSBlock.getRSBlocks(typeNumber, @errorCorrectLevel)

				buffer = new wiz.framework.util.qr.BitBuffer()
				totalDataCount = 0
				for i in [0...rsBlocks.length]
					totalDataCount += rsBlocks[i].dataCount

				for i in [0...@dataList.length]
					data = @dataList[i]
					buffer.put(data.mode, 4)
					buffer.put(data.getLength(), wiz.framework.util.qr.Util.getLengthInBits(data.mode, typeNumber) )
					data.write(buffer)

				if buffer.getLengthInBits() <= totalDataCount * 8
					break

			@typeNumber = typeNumber

		@makeImpl(false, @getBestMaskPattern())
	#}}}
	makeImpl: (test, maskPattern) => #{{{
		@moduleCount = @typeNumber * 4 + 17
		@modules = new Array(@moduleCount)

		for row in [0...@moduleCount]

			@modules[row] = new Array(@moduleCount)

			for col in [0...@moduleCount]
				@modules[row][col] = null;#(col + row) % 3

		@setupPositionProbePattern(0, 0)
		@setupPositionProbePattern(@moduleCount - 7, 0)
		@setupPositionProbePattern(0, @moduleCount - 7)
		@setupPositionAdjustPattern()
		@setupTimingPattern()
		@setupTypeInfo(test, maskPattern)

		if @typeNumber >= 7
			@setupTypeNumber(test)

		if @dataCache == null
			@dataCache = wiz.framework.util.qr.Code.createData(@typeNumber, @errorCorrectLevel, @dataList)

		@mapData(@dataCache, maskPattern)
	#}}}
	setupPositionProbePattern: (row, col) => #{{{
		for r in [-1..7]
			if row + r <= -1 or @moduleCount <= row + r
				continue
			for c in [-1..7]
				if col + c <= -1 or @moduleCount <= col + c
					continue
				if (0 <= r and r <= 6 and (c is 0 or c is 6)) or (0 <= c and c <= 6 and (r is 0 or r is 6)) or (2 <= r and r <= 4 and 2 <= c and c <= 4)
					@modules[row + r][col + c] = true
				else
					@modules[row + r][col + c] = false
	#}}}
	getBestMaskPattern: () => #{{{
		minLostPoint = 0
		pattern = 0

		for i in [0...8]

			@makeImpl(true, i)

			lostPoint = wiz.framework.util.qr.Util.getLostPoint(this)

			if i == 0 || minLostPoint > lostPoint
				minLostPoint = lostPoint
				pattern = i

		return pattern
	#}}}
	createMovieClip: (target_mc, instance_name, depth) => #{{{

		qr_mc = target_mc.createEmptyMovieClip(instance_name, depth)
		cs = 1

		@make()

		for row in [0...@modules.length]

			y = row * cs

			for col in [0...@modules[row].length]

				x = col * cs
				dark = @modules[row][col]

				if dark
					qr_mc.beginFill(0, 100)
					qr_mc.moveTo(x, y)
					qr_mc.lineTo(x + cs, y)
					qr_mc.lineTo(x + cs, y + cs)
					qr_mc.lineTo(x, y + cs)
					qr_mc.endFill()

		return qr_mc
	#}}}
	setupTimingPattern: () => #{{{

		for r in [8...@moduleCount-8]
			if (@modules[r][6] != null)
				continue
			@modules[r][6] = (r % 2 == 0)

		for c in [8...@moduleCount-8]
			if @modules[6][c] != null
				continue
			@modules[6][c] = (c % 2 == 0)
	#}}}
	setupPositionAdjustPattern: () => #{{{

		pos = wiz.framework.util.qr.Util.getPatternPosition(@typeNumber)

		for i in [0...pos.length]

			for j in [0...pos.length]

				row = pos[i]
				col = pos[j]

				if @modules[row][col] != null
					continue

				for r in [-2..2]

					for c in [-2..2]

						if (r == -2 || r == 2 || c == -2 || c == 2 || (r == 0 && c == 0) )
							@modules[row + r][col + c] = true
						else
							@modules[row + r][col + c] = false
	#}}}
	setupTypeNumber: (test) => #{{{

		bits = wiz.framework.util.qr.Util.getBCHTypeNumber(@typeNumber)

		for i in [0...18]
			mod = (!test && ( (bits >> i) & 1) == 1)
			@modules[Math.floor(i / 3)][i % 3 + @moduleCount - 8 - 3] = mod

		for i in [0...18]
			mod = (!test && ( (bits >> i) & 1) == 1)
			@modules[i % 3 + @moduleCount - 8 - 3][Math.floor(i / 3)] = mod
	#}}}
	setupTypeInfo: (test, maskPattern) => #{{{

		data = (@errorCorrectLevel << 3) | maskPattern
		bits = wiz.framework.util.qr.Util.getBCHTypeInfo(data)

		# vertical
		for i in [0...15]

			mod = (!test && ( (bits >> i) & 1) == 1)

			if (i < 6)
				@modules[i][8] = mod
			else if (i < 8)
				@modules[i + 1][8] = mod
			else
				@modules[@moduleCount - 15 + i][8] = mod

		# horizontal
		for i in [0...15]

			mod = (!test && ( (bits >> i) & 1) == 1)

			if (i < 8)
				@modules[8][@moduleCount - i - 1] = mod
			else if (i < 9)
				@modules[8][15 - i - 1 + 1] = mod
			else
				@modules[8][15 - i - 1] = mod

		# fixed module
		@modules[@moduleCount - 8][8] = (!test)
	#}}}
	mapData: (data, maskPattern) => #{{{

		inc = -1
		row = @moduleCount - 1
		bitIndex = 7
		byteIndex = 0

		for col in [@moduleCount-1...0] by -2
			if (col == 6) then col--

			loop
				for c in [0...2]
					if (@modules[row][col - c] == null)

						dark = false

						if (byteIndex < data.length)
							dark = ( ( (data[byteIndex] >>> bitIndex) & 1) == 1)

						mask = wiz.framework.util.qr.Util.getMask(maskPattern, row, col - c)

						if (mask)
							dark = !dark

						@modules[row][col - c] = dark
						bitIndex--

						if (bitIndex == -1)
							byteIndex++
							bitIndex = 7

				row += inc

				if (row < 0 || @moduleCount <= row)
					row -= inc
					inc = -inc
					break
	#}}}
	@PAD0: 0xEC
	@PAD1: 0x11

	@createData: (typeNumber, errorCorrectLevel, dataList) => #{{{

		rsBlocks = wiz.framework.util.qr.RSBlock.getRSBlocks(typeNumber, errorCorrectLevel)

		buffer = new wiz.framework.util.qr.BitBuffer()

		for i in [0...dataList.length]
			data = dataList[i]
			buffer.put(data.mode, 4)
			buffer.put(data.getLength(), wiz.framework.util.qr.Util.getLengthInBits(data.mode, typeNumber) )
			data.write(buffer)

		# calc num max data.
		totalDataCount = 0
		for i in [0...rsBlocks.length]
			totalDataCount += rsBlocks[i].dataCount

		if buffer.getLengthInBits() > totalDataCount * 8
			throw new Error("code length overflow. ("
				+ buffer.getLengthInBits()
				+ ">"
				+  totalDataCount * 8
				+ ")")

		# end code
		if buffer.getLengthInBits() + 4 <= totalDataCount * 8
			buffer.put(0, 4)

		# padding
		while buffer.getLengthInBits() % 8 != 0
			buffer.putBit(false)

		# padding
		loop
			break if buffer.getLengthInBits() >= totalDataCount * 8
			buffer.put(wiz.framework.util.qr.Code.PAD0, 8)
			break if buffer.getLengthInBits() >= totalDataCount * 8
			buffer.put(wiz.framework.util.qr.Code.PAD1, 8)

		return wiz.framework.util.qr.Code.createBytes(buffer, rsBlocks)
	#}}}
	@createBytes: (buffer, rsBlocks) => #{{{

		offset = 0

		maxDcCount = 0
		maxEcCount = 0

		dcdata = new Array(rsBlocks.length)
		ecdata = new Array(rsBlocks.length)

		for r in [0...rsBlocks.length]

			dcCount = rsBlocks[r].dataCount
			ecCount = rsBlocks[r].totalCount - dcCount

			maxDcCount = Math.max(maxDcCount, dcCount)
			maxEcCount = Math.max(maxEcCount, ecCount)

			dcdata[r] = new Array(dcCount)

			for i in [0...dcdata[r].length]
				dcdata[r][i] = 0xff & buffer.buffer[i + offset]

			offset += dcCount

			rsPoly = wiz.framework.util.qr.Util.getErrorCorrectPolynomial(ecCount)
			rawPoly = new wiz.framework.util.qr.Polynomial(dcdata[r], rsPoly.getLength() - 1)

			modPoly = rawPoly.mod(rsPoly)
			ecdata[r] = new Array(rsPoly.getLength() - 1)

			for i in [0...ecdata[r].length]
				modIndex = i + modPoly.getLength() - ecdata[r].length
				ecdata[r][i] = (if modIndex >= 0 then modPoly.get(modIndex) else 0)

		totalCodeCount = 0

		for i in [0...rsBlocks.length]
			totalCodeCount += rsBlocks[i].totalCount

		data = new Array(totalCodeCount)
		index = 0

		for i in [0...maxDcCount]
			for r in [0...rsBlocks.length]
				if i < dcdata[r].length
					data[index++] = dcdata[r][i]

		for i in [0...maxEcCount]
			for r in [0...rsBlocks.length]
				if i < ecdata[r].length
					data[index++] = ecdata[r][i]

		return data
	#}}}
#}}}

class wiz.framework.util.qr.Mode #{{{
	@MODE_NUMBER :		1 << 0
	@MODE_ALPHA_NUM : 	1 << 1
	@MODE_8BIT_BYTE : 	1 << 2
	@MODE_KANJI :		1 << 3
#}}}
class wiz.framework.util.qr.ErrorCorrectLevel #{{{
	@L : 1
	@M : 0
	@Q : 3
	@H : 2
#}}}

class wiz.framework.util.qr.MaskPattern #{{{
	@PATTERN000 : 0
	@PATTERN001 : 1
	@PATTERN010 : 2
	@PATTERN011 : 3
	@PATTERN100 : 4
	@PATTERN101 : 5
	@PATTERN110 : 6
	@PATTERN111 : 7
#}}}

class wiz.framework.util.qr.Util #{{{

	@PATTERN_POSITION_TABLE : [ #{{{
		[],
		[6, 18],
		[6, 22],
		[6, 26],
		[6, 30],
		[6, 34],
		[6, 22, 38],
		[6, 24, 42],
		[6, 26, 46],
		[6, 28, 50],
		[6, 30, 54],
		[6, 32, 58],
		[6, 34, 62],
		[6, 26, 46, 66],
		[6, 26, 48, 70],
		[6, 26, 50, 74],
		[6, 30, 54, 78],
		[6, 30, 56, 82],
		[6, 30, 58, 86],
		[6, 34, 62, 90],
		[6, 28, 50, 72, 94],
		[6, 26, 50, 74, 98],
		[6, 30, 54, 78, 102],
		[6, 28, 54, 80, 106],
		[6, 32, 58, 84, 110],
		[6, 30, 58, 86, 114],
		[6, 34, 62, 90, 118],
		[6, 26, 50, 74, 98, 122],
		[6, 30, 54, 78, 102, 126],
		[6, 26, 52, 78, 104, 130],
		[6, 30, 56, 82, 108, 134],
		[6, 34, 60, 86, 112, 138],
		[6, 30, 58, 86, 114, 142],
		[6, 34, 62, 90, 118, 146],
		[6, 30, 54, 78, 102, 126, 150],
		[6, 24, 50, 76, 102, 128, 154],
		[6, 28, 54, 80, 106, 132, 158],
		[6, 32, 58, 84, 110, 136, 162],
		[6, 26, 54, 82, 110, 138, 166],
		[6, 30, 58, 86, 114, 142, 170]
	]

	@G15: (1 << 10) | (1 << 8) | (1 << 5) | (1 << 4) | (1 << 2) | (1 << 1) | (1 << 0)
	@G18: (1 << 12) | (1 << 11) | (1 << 10) | (1 << 9) | (1 << 8) | (1 << 5) | (1 << 2) | (1 << 0)
	@G15_MASK: (1 << 14) | (1 << 12) | (1 << 10)	| (1 << 4) | (1 << 1)
	#}}}

	@getBCHTypeInfo: (data) => #{{{
		d = data << 10
		while wiz.framework.util.qr.Util.getBCHDigit(d) - wiz.framework.util.qr.Util.getBCHDigit(wiz.framework.util.qr.Util.G15) >= 0
			d ^= (wiz.framework.util.qr.Util.G15 << (wiz.framework.util.qr.Util.getBCHDigit(d) - wiz.framework.util.qr.Util.getBCHDigit(wiz.framework.util.qr.Util.G15) ) )
		return ( (data << 10) | d) ^ wiz.framework.util.qr.Util.G15_MASK
	#}}}
	@getBCHTypeNumber: (data) => #{{{
		d = data << 12
		while wiz.framework.util.qr.Util.getBCHDigit(d) - wiz.framework.util.qr.Util.getBCHDigit(wiz.framework.util.qr.Util.G18) >= 0
			d ^= (wiz.framework.util.qr.Util.G18 << (wiz.framework.util.qr.Util.getBCHDigit(d) - wiz.framework.util.qr.Util.getBCHDigit(wiz.framework.util.qr.Util.G18) ) )
		return (data << 12) | d
	#}}}
	@getBCHDigit: (data) => #{{{

		digit = 0

		while data != 0
			digit++
			data >>>= 1

		return digit
	#}}}
	@getPatternPosition: (typeNumber) => #{{{
		return wiz.framework.util.qr.Util.PATTERN_POSITION_TABLE[typeNumber - 1]
	#}}}
	@getMask: (maskPattern, i, j) => #{{{

		switch maskPattern

			when wiz.framework.util.qr.MaskPattern.PATTERN000 then return (i + j) % 2 == 0
			when wiz.framework.util.qr.MaskPattern.PATTERN001 then return i % 2 == 0
			when wiz.framework.util.qr.MaskPattern.PATTERN010 then return j % 3 == 0
			when wiz.framework.util.qr.MaskPattern.PATTERN011 then return (i + j) % 3 == 0
			when wiz.framework.util.qr.MaskPattern.PATTERN100 then return (Math.floor(i / 2) + Math.floor(j / 3) ) % 2 == 0
			when wiz.framework.util.qr.MaskPattern.PATTERN101 then return (i * j) % 2 + (i * j) % 3 == 0
			when wiz.framework.util.qr.MaskPattern.PATTERN110 then return ( (i * j) % 2 + (i * j) % 3) % 2 == 0
			when wiz.framework.util.qr.MaskPattern.PATTERN111 then return ( (i * j) % 3 + (i + j) % 2) % 2 == 0

			else
				throw new Error("bad maskPattern:" + maskPattern)
	#}}}
	@getErrorCorrectPolynomial: (errorCorrectLength) => #{{{

		a = new wiz.framework.util.qr.Polynomial([1], 0)

		for i in [0...errorCorrectLength]
			a = a.multiply(new wiz.framework.util.qr.Polynomial([1, wiz.framework.util.qr.Math.gexp(i)], 0) )

		return a
	#}}}
	@getLengthInBits: (mode, type) => #{{{

		if 1 <= type && type < 10 # 1 - 9

			switch mode
				when wiz.framework.util.qr.Mode.MODE_NUMBER 	then return 10
				when wiz.framework.util.qr.Mode.MODE_ALPHA_NUM 	then return 9
				when wiz.framework.util.qr.Mode.MODE_8BIT_BYTE	then return 8
				when wiz.framework.util.qr.Mode.MODE_KANJI  	then return 8
				else throw new Error("mode:" + mode)

		else if type < 27 # 10 - 26

			switch mode
				when wiz.framework.util.qr.Mode.MODE_NUMBER 	then return 12
				when wiz.framework.util.qr.Mode.MODE_ALPHA_NUM 	then return 11
				when wiz.framework.util.qr.Mode.MODE_8BIT_BYTE	then return 16
				when wiz.framework.util.qr.Mode.MODE_KANJI  	then return 10
				else throw new Error("mode:" + mode)

		else if type < 41 # 27 - 40

			switch mode
				when wiz.framework.util.qr.Mode.MODE_NUMBER 	then return 14
				when wiz.framework.util.qr.Mode.MODE_ALPHA_NUM	then return 13
				when wiz.framework.util.qr.Mode.MODE_8BIT_BYTE	then return 16
				when wiz.framework.util.qr.Mode.MODE_KANJI  	then return 12
				else throw new Error("mode:" + mode)

		else
			throw new Error("type:" + type)
	#}}}
	@getLostPoint: (qrCode) => #{{{

		moduleCount = qrCode.getModuleCount()

		lostPoint = 0

		# LEVEL1

		for row in [0...moduleCount]

			for col in [0...moduleCount]

				sameCount = 0
				dark = qrCode.isDark(row, col)

			for r in [-1..1]

					if row + r < 0 || moduleCount <= row + r
						continue

					for c in [-1..1]

						if col + c < 0 || moduleCount <= col + c
							continue

						if r == 0 && c == 0
							continue

						if dark == qrCode.isDark(row + r, col + c)
							sameCount++

				if sameCount > 5
					lostPoint += (3 + sameCount - 5)

		# LEVEL2

		for row in [0...moduleCount-1]
			for col in [0...moduleCount-1]
				count = 0
				if qrCode.isDark(row,     col    ) then count++
				if qrCode.isDark(row + 1, col    ) then count++
				if qrCode.isDark(row,     col + 1) then count++
				if qrCode.isDark(row + 1, col + 1) then count++
				if count == 0 || count == 4
					lostPoint += 3

		# LEVEL3

		for row in [0...moduleCount]
			for col in [0...moduleCount-6]
				if (
					qrCode.isDark(row, col) and
					!qrCode.isDark(row, col + 1) and
					qrCode.isDark(row, col + 2) and
					qrCode.isDark(row, col + 3) and
					qrCode.isDark(row, col + 4) and
					!qrCode.isDark(row, col + 5) and
					qrCode.isDark(row, col + 6)
				)
					lostPoint += 40

		for col in [0...moduleCount]
			for row in [0...moduleCount-6]
				if (
					qrCode.isDark(row, col) and
					!qrCode.isDark(row + 1, col) and
					qrCode.isDark(row + 2, col) and
					qrCode.isDark(row + 3, col) and
					qrCode.isDark(row + 4, col) and
					!qrCode.isDark(row + 5, col) and
					qrCode.isDark(row + 6, col)
				)
					lostPoint += 40

		# LEVEL4

		darkCount = 0

		for col in [0...moduleCount]
			for row in [0...moduleCount]
				if qrCode.isDark(row, col)
					darkCount++

		ratio = Math.abs(100 * darkCount / moduleCount / moduleCount - 50) / 5
		lostPoint += ratio * 10

		return lostPoint
#}}}
#}}}
class wiz.framework.util.qr.Math #{{{

	@init: () -> #{{{
		wiz.framework.util.qr.Math.EXP_TABLE = new Array(256)
		wiz.framework.util.qr.Math.LOG_TABLE = new Array(256)

		for i in [0...8]
			wiz.framework.util.qr.Math.EXP_TABLE[i] = 1 << i
		for i in [8...256]
			wiz.framework.util.qr.Math.EXP_TABLE[i] = (
				wiz.framework.util.qr.Math.EXP_TABLE[i - 4] ^
				wiz.framework.util.qr.Math.EXP_TABLE[i - 5] ^
				wiz.framework.util.qr.Math.EXP_TABLE[i - 6] ^
				wiz.framework.util.qr.Math.EXP_TABLE[i - 8]
			)
		for i in [0...255]
			wiz.framework.util.qr.Math.LOG_TABLE[wiz.framework.util.qr.Math.EXP_TABLE[i]] = i
	#}}}
	@glog: (n) -> #{{{

		if (n < 1)
			throw new Error("glog(" + n + ")")

		return wiz.framework.util.qr.Math.LOG_TABLE[n]
	#}}}
	@gexp: (n) -> #{{{

		while (n < 0)
			n += 255

		while (n >= 256)
			n -= 255

		return wiz.framework.util.qr.Math.EXP_TABLE[n]
	#}}}

	@EXP_TABLE: null
	@LOG_TABLE: null
#}}}
class wiz.framework.util.qr.Polynomial #{{{
	constructor: (num, shift) -> #{{{
		if num.length is undefined
			throw new Error(num.length + "/" + shift)

		offset = 0

		while offset < num.length && num[offset] == 0
			offset++

		@num = new Array(num.length - offset + shift)
		for i in [0...num.length-offset]
			@num[i] = num[i + offset]
	#}}}
	get: (index) => #{{{
		return @num[index]
	#}}}
	getLength: () => #{{{
		return @num.length
	#}}}
	multiply: (e) => #{{{
		num = new Array(@getLength() + e.getLength() - 1)

		for i in [0...@getLength()]
			for j in [0...e.getLength()]
				num[i + j] ^= wiz.framework.util.qr.Math.gexp(wiz.framework.util.qr.Math.glog(@get(i) ) + wiz.framework.util.qr.Math.glog(e.get(j) ) )

		return new wiz.framework.util.qr.Polynomial(num, 0)
	#}}}
	mod: (e) => #{{{
		if @getLength() - e.getLength() < 0
			return this

		ratio = wiz.framework.util.qr.Math.glog(@get(0) ) - wiz.framework.util.qr.Math.glog(e.get(0) )

		num = new Array(@getLength() )

		for i in [0...@getLength()]
			num[i] = @get(i)

		for i in [0...e.getLength()]
			num[i] ^= wiz.framework.util.qr.Math.gexp(wiz.framework.util.qr.Math.glog(e.get(i) ) + ratio)

		# recursive call
		return new wiz.framework.util.qr.Polynomial(num, 0).mod(e)
	#}}}
#}}}
class wiz.framework.util.qr.RSBlock #{{{
	@RS_BLOCK_TABLE = [ #{{{

		# L
		# M
		# Q
		# H

		# 1
		[1, 26, 19]
		[1, 26, 16]
		[1, 26, 13]
		[1, 26, 9]

		# 2
		[1, 44, 34]
		[1, 44, 28]
		[1, 44, 22]
		[1, 44, 16]

		# 3
		[1, 70, 55]
		[1, 70, 44]
		[2, 35, 17]
		[2, 35, 13]

		# 4
		[1, 100, 80]
		[2, 50, 32]
		[2, 50, 24]
		[4, 25, 9]

		# 5
		[1, 134, 108]
		[2, 67, 43]
		[2, 33, 15, 2, 34, 16]
		[2, 33, 11, 2, 34, 12]

		# 6
		[2, 86, 68]
		[4, 43, 27]
		[4, 43, 19]
		[4, 43, 15]

		# 7
		[2, 98, 78]
		[4, 49, 31]
		[2, 32, 14, 4, 33, 15]
		[4, 39, 13, 1, 40, 14]

		# 8
		[2, 121, 97]
		[2, 60, 38, 2, 61, 39]
		[4, 40, 18, 2, 41, 19]
		[4, 40, 14, 2, 41, 15]

		# 9
		[2, 146, 116]
		[3, 58, 36, 2, 59, 37]
		[4, 36, 16, 4, 37, 17]
		[4, 36, 12, 4, 37, 13]

		# 10
		[2, 86, 68, 2, 87, 69]
		[4, 69, 43, 1, 70, 44]
		[6, 43, 19, 2, 44, 20]
		[6, 43, 15, 2, 44, 16]

		# 11
		[4, 101, 81]
		[1, 80, 50, 4, 81, 51]
		[4, 50, 22, 4, 51, 23]
		[3, 36, 12, 8, 37, 13]

		# 12
		[2, 116, 92, 2, 117, 93]
		[6, 58, 36, 2, 59, 37]
		[4, 46, 20, 6, 47, 21]
		[7, 42, 14, 4, 43, 15]

		# 13
		[4, 133, 107]
		[8, 59, 37, 1, 60, 38]
		[8, 44, 20, 4, 45, 21]
		[12, 33, 11, 4, 34, 12]

		# 14
		[3, 145, 115, 1, 146, 116]
		[4, 64, 40, 5, 65, 41]
		[11, 36, 16, 5, 37, 17]
		[11, 36, 12, 5, 37, 13]

		# 15
		[5, 109, 87, 1, 110, 88]
		[5, 65, 41, 5, 66, 42]
		[5, 54, 24, 7, 55, 25]
		[11, 36, 12]

		# 16
		[5, 122, 98, 1, 123, 99]
		[7, 73, 45, 3, 74, 46]
		[15, 43, 19, 2, 44, 20]
		[3, 45, 15, 13, 46, 16]

		# 17
		[1, 135, 107, 5, 136, 108]
		[10, 74, 46, 1, 75, 47]
		[1, 50, 22, 15, 51, 23]
		[2, 42, 14, 17, 43, 15]

		# 18
		[5, 150, 120, 1, 151, 121]
		[9, 69, 43, 4, 70, 44]
		[17, 50, 22, 1, 51, 23]
		[2, 42, 14, 19, 43, 15]

		# 19
		[3, 141, 113, 4, 142, 114]
		[3, 70, 44, 11, 71, 45]
		[17, 47, 21, 4, 48, 22]
		[9, 39, 13, 16, 40, 14]

		# 20
		[3, 135, 107, 5, 136, 108]
		[3, 67, 41, 13, 68, 42]
		[15, 54, 24, 5, 55, 25]
		[15, 43, 15, 10, 44, 16]

		# 21
		[4, 144, 116, 4, 145, 117]
		[17, 68, 42]
		[17, 50, 22, 6, 51, 23]
		[19, 46, 16, 6, 47, 17]

		# 22
		[2, 139, 111, 7, 140, 112]
		[17, 74, 46]
		[7, 54, 24, 16, 55, 25]
		[34, 37, 13]

		# 23
		[4, 151, 121, 5, 152, 122]
		[4, 75, 47, 14, 76, 48]
		[11, 54, 24, 14, 55, 25]
		[16, 45, 15, 14, 46, 16]

		# 24
		[6, 147, 117, 4, 148, 118]
		[6, 73, 45, 14, 74, 46]
		[11, 54, 24, 16, 55, 25]
		[30, 46, 16, 2, 47, 17]

		# 25
		[8, 132, 106, 4, 133, 107]
		[8, 75, 47, 13, 76, 48]
		[7, 54, 24, 22, 55, 25]
		[22, 45, 15, 13, 46, 16]

		# 26
		[10, 142, 114, 2, 143, 115]
		[19, 74, 46, 4, 75, 47]
		[28, 50, 22, 6, 51, 23]
		[33, 46, 16, 4, 47, 17]

		# 27
		[8, 152, 122, 4, 153, 123]
		[22, 73, 45, 3, 74, 46]
		[8, 53, 23, 26, 54, 24]
		[12, 45, 15, 28, 46, 16]

		# 28
		[3, 147, 117, 10, 148, 118]
		[3, 73, 45, 23, 74, 46]
		[4, 54, 24, 31, 55, 25]
		[11, 45, 15, 31, 46, 16]

		# 29
		[7, 146, 116, 7, 147, 117]
		[21, 73, 45, 7, 74, 46]
		[1, 53, 23, 37, 54, 24]
		[19, 45, 15, 26, 46, 16]

		# 30
		[5, 145, 115, 10, 146, 116]
		[19, 75, 47, 10, 76, 48]
		[15, 54, 24, 25, 55, 25]
		[23, 45, 15, 25, 46, 16]

		# 31
		[13, 145, 115, 3, 146, 116]
		[2, 74, 46, 29, 75, 47]
		[42, 54, 24, 1, 55, 25]
		[23, 45, 15, 28, 46, 16]

		# 32
		[17, 145, 115]
		[10, 74, 46, 23, 75, 47]
		[10, 54, 24, 35, 55, 25]
		[19, 45, 15, 35, 46, 16]

		# 33
		[17, 145, 115, 1, 146, 116]
		[14, 74, 46, 21, 75, 47]
		[29, 54, 24, 19, 55, 25]
		[11, 45, 15, 46, 46, 16]

		# 34
		[13, 145, 115, 6, 146, 116]
		[14, 74, 46, 23, 75, 47]
		[44, 54, 24, 7, 55, 25]
		[59, 46, 16, 1, 47, 17]

		# 35
		[12, 151, 121, 7, 152, 122]
		[12, 75, 47, 26, 76, 48]
		[39, 54, 24, 14, 55, 25]
		[22, 45, 15, 41, 46, 16]

		# 36
		[6, 151, 121, 14, 152, 122]
		[6, 75, 47, 34, 76, 48]
		[46, 54, 24, 10, 55, 25]
		[2, 45, 15, 64, 46, 16]

		# 37
		[17, 152, 122, 4, 153, 123]
		[29, 74, 46, 14, 75, 47]
		[49, 54, 24, 10, 55, 25]
		[24, 45, 15, 46, 46, 16]

		# 38
		[4, 152, 122, 18, 153, 123]
		[13, 74, 46, 32, 75, 47]
		[48, 54, 24, 14, 55, 25]
		[42, 45, 15, 32, 46, 16]

		# 39
		[20, 147, 117, 4, 148, 118]
		[40, 75, 47, 7, 76, 48]
		[43, 54, 24, 22, 55, 25]
		[10, 45, 15, 67, 46, 16]

		# 40
		[19, 148, 118, 6, 149, 119]
		[18, 75, 47, 31, 76, 48]
		[34, 54, 24, 34, 55, 25]
		[20, 45, 15, 61, 46, 16]
	] #}}}

	constructor: (@totalCount, @dataCount) -> #{{{
	#}}}
	@getRSBlocks: (typeNumber, errorCorrectLevel) => #{{{

		rsBlock = wiz.framework.util.qr.RSBlock.getRsBlockTable(typeNumber, errorCorrectLevel)

		if rsBlock is undefined
			throw new Error("bad rs block @ typeNumber:" + typeNumber + "/errorCorrectLevel:" + errorCorrectLevel)

		length = rsBlock.length / 3

		list = new Array()

		for i in [0...length]

			count = rsBlock[i * 3 + 0]
			totalCount = rsBlock[i * 3 + 1]
			dataCount  = rsBlock[i * 3 + 2]

			for j in [0...count]
				list.push(new wiz.framework.util.qr.RSBlock(totalCount, dataCount) )

		return list
	#}}}
	@getRsBlockTable: (typeNumber, errorCorrectLevel) => #{{{
		switch errorCorrectLevel
			when wiz.framework.util.qr.ErrorCorrectLevel.L
				return wiz.framework.util.qr.RSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 0]
			when wiz.framework.util.qr.ErrorCorrectLevel.M
				return wiz.framework.util.qr.RSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 1]
			when wiz.framework.util.qr.ErrorCorrectLevel.Q
				return wiz.framework.util.qr.RSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 2]
			when wiz.framework.util.qr.ErrorCorrectLevel.H
				return wiz.framework.util.qr.RSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 3]
			else
				return undefined
	#}}}
#}}}
class wiz.framework.util.qr.BitBuffer #{{{
	constructor: () -> #{{{
		@buffer = new Array()
		@length = 0
	#}}}
	get: (index) => #{{{
		bufIndex = Math.floor(index / 8)
		return ( (@buffer[bufIndex] >>> (7 - index % 8) ) & 1) == 1
	#}}}
	put: (num, length) => #{{{
		for i in [0...length]
			@putBit( ( (num >>> (length - i - 1) ) & 1) == 1)
	#}}}
	getLengthInBits: () => #{{{
		return @length
	#}}}
	putBit: (bit) => #{{{
		bufIndex = Math.floor(@length / 8)
		if @buffer.length <= bufIndex
			@buffer.push(0)

		if bit
			@buffer[bufIndex] |= (0x80 >>> (@length % 8) )

		@length++
	#}}}
#}}}

# init math tables
wiz.framework.util.qr.Math.init()

# vim: foldmethod=marker wrap
