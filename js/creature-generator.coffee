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
			segment_h = @creature.scaled_h / 10
			for i in [0...10]
				points.push(new Phaser.Point(0, i * segment_h))

			# @sprite = @game.add.sprite(@creature.x, @creature.y, @creature.bitmap)
			@sprite = game.add.rope(@creature.x, @creature.y, @creature.bitmap, null, points)
			window.s = @sprite

			@sprite.angle = -90 if @sprite.type == Phaser.ROPE

			count = 0
			@sprite.updateAnimation = ->
				count += 0.1
				for i in  [0...points.length]
					points[i].x = Math.sin(i * 0.5  + count) * 2

			controller = gui.add @creature, 'seed'
			gui.add @creature, 'grid'
			gui.addColor @creature, 'color'

	start()