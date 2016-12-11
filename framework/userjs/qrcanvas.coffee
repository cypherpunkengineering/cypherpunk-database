
class wiz.portal.userjs.qrcanvas
	constructor: (options = {}) -> #{{{
		# width and height in pixel
		@width = options.width || 150
		@height = options.height || 150

		# optional white border in em, to help scanning
		@border = options.border || 0.5

		# code color
		@foreground = options.foreground || '#000'

		# background color, `null` for transparent background
		@background = options.background || '#fff'

		# the encoded text
		@text = options.text || 'text'

		# defaults
		@typeNumber = -1
		@correctLevel = wiz.framework.util.qr.ErrorCorrectLevel.H

	#}}}
	render: () =>
		# create container
		@container = $('<div>')
		@container.css('background-color', @background)
		@container.css('padding', @border + 'em')
		@container.css('display', 'inline-block')

		# create the qr code object
		@qrc = new wiz.framework.util.qr.Code(@typeNumber, @correctLevel)
		@qrc.addData(@text)
		@qrc.make()

		# create canvas element
		canvas = document.createElement("canvas")
		canvas.width = @width
		canvas.height = @height
		ctx = canvas.getContext("2d")

		# compute tileW/tileH based on @width/@height
		tileW = @width / @qrc.getModuleCount()
		tileH = @height / @qrc.getModuleCount()

		# draw in the canvas
		for row in [0..@qrc.getModuleCount()-1]
			str = ''
			for col in [0..@qrc.getModuleCount()-1]
				str += (if @qrc.isDark(row, col) then '1' else '0')
				ctx.fillStyle = (if @qrc.isDark(row, col) then @foreground else @background)
				w = (Math.ceil((col + 1) * tileW) - Math.floor(col * tileW))
				h = (Math.ceil((row + 1) * tileW) - Math.floor(row * tileW))
				ctx.fillRect Math.round(col * tileW), Math.round(row * tileH), w, h
			console.log str

		# add canvas to container
		@container.append(canvas)
		return @container

# vim: foldmethod=marker wrap
