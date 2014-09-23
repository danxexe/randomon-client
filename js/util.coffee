if Phaser?

	Phaser.RandomDataGenerator::color = ->
		r = @between(0, 255)
		g = @between(0, 255)
		b = @between(0, 255)

		Phaser.Color.getColor32(1, r, g, b)

	Phaser.Color.toArray = (color) ->
		[Phaser.Color.getRed(color), Phaser.Color.getGreen(color), Phaser.Color.getBlue(color)]

	Phaser.BitmapData.prototype._fill = Phaser.BitmapData.prototype.fill
	Phaser.BitmapData.prototype.fill = (r, g, b, a) ->
		if typeof r == 'number' && g == undefined && b == undefined && a == undefined
			# Expecting a constant like 0xRRGGBB or 0xAARRGGBB
			color = Phaser.Color.getRGB(r)
			@_fill color.r, color.g, color.b, color.a
		else
			@_fill r, g, b, a

if CanvasRenderingContext2D?
	CanvasRenderingContext2D::grid = (w, h, style = {}) ->
		@strokeStyle = style.color ?= '#000'
		@lineWidth = style.width ?= 1
		@beginPath()

		scale_x = @canvas.width / w
		scale_y = @canvas.height / h

		scaled_y = h * scale_y
		for x in [0..w]
			scaled_x = x * scale_x
			@moveTo(scaled_x, 0)
			@lineTo(scaled_x, scaled_y)
			@stroke()

		scaled_x = w * scale_x
		for y in [0..h]
			scaled_y = y * scale_y
			@moveTo(0, scaled_y)
			@lineTo(scaled_x, scaled_y)
			@stroke()