window.onload = ->

	gui = new dat.GUI()

	start = ->
		w = document.body.offsetWidth
		h = document.body.offsetHeight
		game = new Phaser.Game(w, h, Phaser.AUTO, '', CreatureState)
		window.game = game
		window.state = CreatureState

	CreatureState = 
		create: ->
			@game.stage.backgroundColor = 0xffffff

			@creature = new CreatureBitmap(@game, x: 100, y: 100, color: 0x000000, grid: true, w: 7, h: 8)
			window.c = @creature

			points = []
			num_segments = 10
			segment_size = @creature.scaled_w / num_segments
			for i in [0...num_segments]
				points.push(new PIXI.Point(i * segment_size, 0))

			# @sprite = @game.add.sprite(@creature.x, @creature.y, @creature.bitmap)
			@sprite = game.add.rope(@creature.x, @creature.y, @creature.bitmap, null, points)
			window.s = @sprite

			count = 0
			@sprite.updateAnimation = ->
				count += 2
				for i in  [0...points.length]
					points[i].y = Math.sin((count+(i*3)) * 0.05) * 10;

			controller = gui.add @creature, 'seed'
			gui.add @creature, 'grid'
			gui.addColor @creature, 'color'

	start()