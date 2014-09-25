BattleState = 
	_setupGUI: ->
		game = @game
		gui = @gui = new dat.GUI()
		@gui_controller =
			run: ->
				gui.destroy()
				game.state.start 'game'

		@gui.add(@gui_controller, 'run').name('Run!')

	create: ->
		@_setupGUI()

		@world.setBounds(0, 0, @camera.width, @camera.height)

		@enemy = @_createCreature(x: @world.centerX + 200, y: 100)
		@_createCreatureInfo(x: 40, y: 30)
		@player = @_createCreature(x: 200, y: 400, scale: 16 * 3, seed: @world.player.id)
		@_createCreatureInfo(x: @camera.width - 600, y: @camera.height - 200)

	_createCreature: (options = {}) ->
		options.scale ?= 16
		unless options.seed?
			@game.rnd.sow([Math.random()])
			options.seed = @game.rnd.pick(@world.encounters)

		creature = new Creature(@game, x: options.x, y: options.y, scale: options.scale, color: 0x000000, w: 7, h: 8, seed: options.seed)
		creature.addTo @game

	_createCreatureInfo: (options = {}) ->
		info = @game.add.group()
		info.x = options.x
		info.y = options.y

		@game.add.text 0, 0, "Unknown", { font: "40px Minecraftia" }, info
		window.t = @game.add.text 366, 10, "Lv 01", { font: "30px Minecraftia", align: 'right' }, info
		@game.add.text 0, 50, "HP", { font: "28px Minecraftia" }, info
		hp_bar = @game.add.graphics(60, 58, info)
		hp_bar.lineStyle(4, 0x000000, 1)
		hp_bar.beginFill(0x9DE0AD, 1)
		hp_bar.drawRect(0, 0, 400, 24)

window.BattleState = BattleState