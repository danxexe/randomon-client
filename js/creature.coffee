class Creature extends CreatureBitmap
	constructor: (@game, @options = {}) ->
		super(@game, @options)

		@points = []
		@num_segments = 10
		@segment_size = @scaled_w / @num_segments
		for i in [0...@num_segments]
			@points.push(new PIXI.Point(i * @segment_size, 0))

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