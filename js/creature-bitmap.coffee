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
		@_color = options.color
		@_grid = options.grid
		@_seed = options.seed ?= @game.rnd.uuid()

		@game.rnd.sow(@seed)
		@data_w = Math.ceil(@w / 2)
		@data = options.data ?= new CreatureData(@game, @data_w, @h).data

		@bitmap = new Phaser.BitmapData(@game, null, @scaled_w, @scaled_h)

		@render()

	Object.defineProperties @prototype,
		grid:
			get: -> @_grid
			set: (val) ->
				@_grid = val
				@render()
		color:
			get: -> @_color
			set: (val) ->
				@_color = val
				@render()
		seed:
			get: -> @_seed
			set: (val) ->
				@_seed = val
				@game.rnd.sow(@seed)
				@data = new CreatureData(@game, @data_w, @h).data
				@bitmap.clear()
				@bitmap.update(0, 0, @scaled_w, @scaled_h)
				@render()

	render: ->
		@bitmap.clear()
		@drawData()
		@drawGrid() if @grid

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

window.CreatureData = CreatureData
window.CreatureBitmap = CreatureBitmap