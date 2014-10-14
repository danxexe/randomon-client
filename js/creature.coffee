class Creature extends CreatureBitmap
	constructor: (@game, @options = {}) ->
		super(@game, @options)

		# Create rope segments

		@points = []
		@num_segments = 10
		@segment_size = @scaled_w / @num_segments
		for i in [0...@num_segments]
			@points.push(new PIXI.Point(i * @segment_size, 0))

		# Creature data

		@base_stats = 
			hp: @game.rnd.between(10, 120)
			atk: @game.rnd.between(10, 120)
			def: @game.rnd.between(10, 120)
			spatk: @game.rnd.between(10, 120)
			spdef: @game.rnd.between(10, 120)
			spd: @game.rnd.between(10, 120)

		@lv = if @options.lv? then @options.lv else 1
		if @options.exp?
			@exp = @options.exp
			@lv = if @exp == 0 then 1 else Math.floor(Math.cbrt(@exp))
		else
			@exp = if @lv == 1 then 0 else @lv ** 3
		@to_next = if @lv == 100 then 0 else ((@lv + 1) ** 3) - @exp

	addTo: (@parent) ->
		@sprite = @parent.add.rope(@x, @y, @bitmap, null, @points)

		count = 0
		points = @points
		@sprite.updateAnimation = ->
			count += 2
			for i in  [0...points.length]
				points[i].y = Math.sin((count+(i*3)) * 0.05) * 10;

		@sprite

window.Creature = Creature