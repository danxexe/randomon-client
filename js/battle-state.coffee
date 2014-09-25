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

		@_createEnemy()
		@_createEnemyInfo()

	_createEnemy: ->
		@game.rnd.sow([Math.random()])
		uuid = @game.rnd.pick(@world.encounters)
		@enemy = new Creature(@game, x: @world.centerX + 200, y: 100, color: 0x000000, w: 7, h: 8, seed: uuid)
		@enemy.addTo @game

	_createEnemyInfo: ->
		info = @game.add.group()
		info.x = 40
		info.y = 30

		@game.add.text 0, 0, "Unknown", { font: "40px Minecraftia" }, info
		window.t = @game.add.text 366, 10, "Lv 01", { font: "30px Minecraftia", align: 'right' }, info
		@game.add.text 0, 50, "HP", { font: "28px Minecraftia" }, info
		@hp_bar = @game.add.graphics(60, 58, info)
		@hp_bar.lineStyle(4, 0x000000, 1)
		@hp_bar.beginFill(0x9DE0AD, 1)
		@hp_bar.drawRect(0, 0, 400, 24)
		window.hp = @hp_bar

window.BattleState = BattleState