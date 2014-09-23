window.onload = ->

	start = ->
		w = document.body.offsetWidth
		h = document.body.offsetHeight
		game = new Phaser.Game(w, h, Phaser.AUTO, '', CreatureState)
		window.game = game
		window.state = CreatureState

	CreatureState = 
		create: ->
			@game.stage.backgroundColor = 0xffffff

			data = new CreatureData(@game, 4, 8)
			@creature = new CreatureBitmap(@game, x: 100, y: 100, color: 0x000000, grid: true, data: data.data, w: (data.w * 2 - 1), h: data.h)
			window.c = @creature

			@sprite = @game.add.sprite(@creature.x, @creature.y, @creature.bitmap)

	class CreatureData
		constructor: (@game, @w, @h) ->
			@data = []
			for i in [0...(@w * @h)]
				@data.push @game.rnd.between(0, 1)
				if i % @w == @w - 1
					for j in [(@data.length - 2)..(@data.length - @w)]
						@data.push @data[j]

	class CreatureBitmap
		constructor: (@game, @options = {}) ->
			@w = @options.w ?= 5
			@h = @options.h ?= 5
			@x = @options.x ?= 0
			@y = @options.y ?= 0
			@scale = @options.scale ?= 16
			@scaled_w = @w * @scale
			@scaled_h = @h * @scale
			@color = options.color
			@grid = options.grid
			@data = options.data ?= []

			@bitmap = new Phaser.BitmapData(@game, null, @scaled_w, @scaled_h)
			@drawData()

			# @drawGrid() if @grid?

		drawData: ->
			@bitmap.smoothed = false
			color = Phaser.Color.getRGB(@color)

			for px, i in @data
				continue unless px
				x = i % @w
				y = ~~(i / @w)
				
				@bitmap.setPixel(x, y, color.r, color.g, color.b, false)

			@bitmap.ctx.putImageData(@bitmap.imageData, 0, 0)
			@bitmap.dirty = true
			@bitmap.ctx.drawImage @bitmap.canvas, 0, 0, @w, @h, 0, 0, @scaled_w, @scaled_h

			# Hack: clear the leftovers of our smaller version
			@bitmap.ctx.clearRect(0, 0, @scale, @scale) if @data[0] == 0

		drawGrid: ->
			@bitmap.ctx.grid @w, @h, width: 1, color: '#dedede'

	start()