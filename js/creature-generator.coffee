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

			@sprite = @game.add.sprite(@creature.x, @creature.y, @creature.bitmap)

			gui.add @creature, 'seed'
			gui.add @creature, 'grid'
			gui.addColor @creature, 'color'

	start()